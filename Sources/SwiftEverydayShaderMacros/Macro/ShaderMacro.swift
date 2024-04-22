import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftEverydayUtils

func containerName(for variable: DeclarationVariable) -> String {
    return "_\(variable.identifier)BufferContainer"
}

public struct ShaderMacro: MemberMacro {
    enum ShaderType {
        static let vertex = "IVertexFunction"
        static let fragment = "IFragmentFunction"
        static let compute = "IComputeFunction"
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let access = declaration.modifiers.contains(where: { $0.name.text == "public " }) ? "public" : ""
        let allVariables = declaration
            .memberBlock
            .members
            .compactMap({ try? DeclarationVariable.make($0) })
        let variables = allVariables.filter({
            $0.attributes.contains {
                $0.name == "Buffer" ||
                $0.name == "IndexBuffer" ||
                $0.name == "TextureBuffer"
            }
        })


        let protocols = declaration.inheritanceClause?.inheritedTypes.map({ $0.type.description.removeSpace() }) ?? []

        let isVertexShader = protocols.contains(where: { value in [ShaderType.vertex].contains(value) })
        let isFragmentShader = protocols.contains(where: { value in [ShaderType.fragment].contains(value) })
        let isComputeShader = protocols.contains(where: { value in [ShaderType.compute].contains(value) })


        let containers = variables.filter({ $0.attributes.contains(where: { $0.name != "TextureBuffer" }) }).map({ makeBufferContainer($0, access: access) })

        var functions: [DeclSyntax] = []
        if isVertexShader {
            let vertexBuffer = variables.filter({ $0.attributes.contains { $0.name == "Buffer" && $0.parameters.contains(where: { $0.label == "vertexCount" && $0.expression == "true" }) } })
            let indexBuffer = variables.filter({ $0.attributes.contains { $0.name == "IndexBuffer" } })
            let vertexCounter = allVariables.filter({
                $0.attributes.contains {
                    $0.name == "VertexCount"
                }
            })
            guard
                ((vertexBuffer.count + indexBuffer.count) > 0 &&
                indexBuffer.count < 2 &&
                vertexBuffer.count < 2) ||
                (vertexBuffer.count + indexBuffer.count == 0 && vertexCounter.count == 1)
            else
            {
                throw SwiftEverydayShaderError("For vertex function it is necessary to add `Buffer(vertexCount: true)` or IndexBuffer in quantity not more than one of each kind or one VertexCount")
            }
            let components = try variables.map({ try vertexFunctionComponent($0) }).joined(separator: "\n")

            functions.append("""
            \(raw: access)var _readyForRendering: Bool {
                \(raw: try readyForRenderingVertexFunction(vertex: vertexBuffer.first, index: indexBuffer.first, counter: vertexCounter.first))
            }
            \(raw: access)func _prepareVertex(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws {
                \(raw: components)
            }

            \(raw: access)func _render(encoder: MTLRenderCommandEncoder, device: MTLDevice, primitive: MTLPrimitiveType) throws {
                \(raw: try renderVertexFunction(vertex: vertexBuffer.first, index: indexBuffer.first, counter: vertexCounter.first))
            }
            """)
        }

        if isFragmentShader {
            let components = try variables.map({ try fragmentFunctionComponent($0) }).joined(separator: "\n")
            functions.append("""
            \(raw: access)func _prepareFragment(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws {
                \(raw: components)
            }
            """)
        }

        if isComputeShader {
            let countBuffer = variables.filter({ $0.attributes.contains { $0.name == "Buffer" && $0.parameters.contains(where: { $0.label == "computeCount" && $0.expression == "true" }) } })
            let computeCounter = allVariables.filter({
                $0.attributes.contains {
                    $0.name == "ComputeCount"
                }
            })
            guard (countBuffer.count == 1 || computeCounter.count == 1) && (countBuffer.count == 0 || computeCounter.count == 0) else {
                throw SwiftEverydayShaderError("For the calculation function, you need to add Buffer(compute Count: true) or Compute Count in a single copy")
            }
            let components = try variables.map({ try computeFunctionComponent($0) }).joined(separator: "\n")
            functions.append("""
            \(raw: access)func _prepareCompute(encoder: MTLComputeCommandEncoder, device: MTLDevice) throws {
                \(raw: components)
            }
            """)
            try functions.append("\(raw: runComputeFunction(array: countBuffer.first, counter: computeCounter.first))")
        }

        return
            containers + functions
    }

    static func makeBufferContainer(_ variable: DeclarationVariable, access: String) -> DeclSyntax {
        var initText = ".init()"
        if let initializer = variable.initializer {
            if variable.type.isArray {
                initText = ".init(\(initializer))"
            } else {
                initText = ".init([\(initializer)])"
            }
        }

        if variable.isSharedContainer {
            return "\(raw: access)var \(raw: containerName(for: variable)): BufferContainer<\(raw: variable.type.type)> = \(raw: initText)"
        } else {
            return "private var \(raw: containerName(for: variable)): BufferContainer<\(raw: variable.type.type)> = \(raw: initText)"
        }
    }

    static func fragmentFunctionComponent(_ variable: DeclarationVariable) throws -> String {
        guard
            let buffer = variable.attributes.first(where: { $0.name == "Buffer" || $0.name == "TextureBuffer" }),
            let index = buffer.parameters.last(where: { $0.label == nil || $0.label == "fragmentIndex" })
        else {
            return ""
        }
        if buffer.name == "TextureBuffer" {
            let optional = variable.type.isOptional ? "?" : ""
            return "try encoder.setFragmentTexture(\(variable.identifier)\(optional).getTexture(for: device) , index: \(index.expression))"
        }
        return "try encoder.setFragmentBuffer(\(containerName(for: variable)).getBuffer(for: device), offset: 0, index: \(index.expression))"
    }

    static func computeFunctionComponent(_ variable: DeclarationVariable) throws -> String {
        guard
            let buffer = variable.attributes.first(where: { $0.name == "Buffer" || $0.name == "TextureBuffer" }),
            let index = buffer.parameters.last(where: { $0.label == nil || $0.label == "fragmentIndex" })
        else {
            return ""
        }
        if buffer.name == "TextureBuffer" {
            let optional = variable.type.isOptional ? "?" : ""
            return "try encoder.setTexture(\(variable.identifier)\(optional).getTexture(for: device) , index: \(index.expression))"
        }
        return "try encoder.setBuffer(\(containerName(for: variable)).getBuffer(for: device), offset: 0, index: \(index.expression))"
    }


    static func vertexFunctionComponent(_ variable: DeclarationVariable) throws -> String {
        guard
            let buffer = variable.attributes.first(where: { $0.name == "Buffer" || $0.name == "TextureBuffer" }),
            let index = buffer.parameters.last(where: { $0.label == nil || $0.label == "vertexIndex" })?.expression
        else {
            return ""
        }
        if buffer.name == "TextureBuffer" {
            let optional = variable.type.isOptional ? "?" : ""
            return "try encoder.setVertexTexture(\(variable.identifier)\(optional).getTexture(for: device) , index: \(index))"
        }
        return "try encoder.setVertexBuffer(\(containerName(for: variable)).getBuffer(for: device), offset: 0, index: \(index))"
    }

    static func readyForRenderingVertexFunction(
        vertex: DeclarationVariable?,
        index: DeclarationVariable?,
        counter: DeclarationVariable?
    ) throws -> String {
        if let vertex, let index {
            guard vertex.type.isArray else {
                throw SwiftEverydayShaderError("vertex must be of type Array")
            }
            if index.type.isOptional {
                return """
                if let \(index.identifier) {
                    guard \(index.identifier).count > 0 else {
                        return false
                    }
                } else {
                    guard \(vertex.identifier).count > 0 else {
                        return false
                    }
                }
                return true
                """
            } else {
                return """
                return \(vertex.identifier).count > 0
                """
            }
        } else if let vertex {
            return """
            return \(vertex.identifier).count > 0
            """
        } else if let index {
            return """
            return \(index.identifier).count > 0
            """
        } else if let counter {
            return """
            return \(counter.identifier) > 0
            """
        } else {
            throw SwiftEverydayShaderError("For vertex function it is necessary to add `Buffer(vertexCount: true)` or IndexBuffer in quantity not more than one of each kind")
        }
    }

    static func runComputeFunction(
        array: DeclarationVariable?,
        counter: DeclarationVariable?
    ) throws -> String {
        let countVar: String
        if let counter = counter ?? (array?.type.isArray == false ? array : nil) {
            if ["UInt", "UInt32", "Int", "Int32"].contains(counter.type.type) {
                countVar = "let __gridSize = MTLSize(width: Int(\(counter.identifier)), height: 1, depth: 1)"
            } else if ["vector_uint2", "vector_int2"].contains(counter.type.type) {
                countVar = "let __gridSize = MTLSize(width: Int(\(counter.identifier).x), height: Int(\(counter.identifier).y), depth: 1)"
            } else if ["vector_uint3", "vector_int3"].contains(counter.type.type) {
                countVar = "let __gridSize = MTLSize(width: Int(\(counter.identifier).x), height: Int(\(counter.identifier).y), depth: Int(\(counter.identifier).z))"
            } else {
                throw SwiftEverydayShaderError("To do this, explicitly specify one of the types: UInt, UInt32, Int, Int32, vector_int2, vector_int3, vector_uint3, vector_uint2")
            }
        } else if let array {
            countVar = "let __gridSize = MTLSize(width: \(array.identifier).count, height: 1, depth: 1)"
        } else {
            throw "Incorrect type"
        }

        return """
        func _runCompute(encoder: MTLComputeCommandEncoder, device: MTLDevice, maxTotalThreadsPerThreadgroup: Int) throws {
            \(countVar)
            let __sumCount = Int(__gridSize.width * __gridSize.height * __gridSize.depth)
            var __threadGroupSize = maxTotalThreadsPerThreadgroup
            if __threadGroupSize > __sumCount {
                __threadGroupSize = __sumCount
            }
            let __threadsPerThreadgroup = MTLSize(width: __threadGroupSize, height: 1, depth: 1)
            encoder.dispatchThreads(__gridSize, threadsPerThreadgroup: __threadsPerThreadgroup)
        }
        """
    }

    static func renderVertexFunction(
        vertex: DeclarationVariable?,
        index: DeclarationVariable?,
        counter: DeclarationVariable?
    ) throws -> String {
        guard counter == nil || (counter?.type.type == "Int" && counter?.type.isArray == false) else {
            throw SwiftEverydayShaderError("count must be of type Int")
        }
        let indexString = { (index: DeclarationVariable) in
            var type = "uint32"
            if index.type.type == "UInt32" && index.type.isArray {
                type = "uint32"
            } else if index.type.type == "UInt16" && index.type.isArray {
                type = "uint16"
            } else {
                throw SwiftEverydayShaderError("index must be of type [UInt16] or [UInt32]")
            }
            return """
            encoder.drawIndexedPrimitives(
                type: primitive,
                indexCount: \(index.identifier).count,
                indexType: .\(type),
                indexBuffer: try \(containerName(for: index)).getBuffer(for: device).noOptional(),
                indexBufferOffset: 0
            )
            """
        }
        if let vertex, let index {
            guard vertex.type.isArray else {
                throw SwiftEverydayShaderError("vertex must be of type Array")
            }
            if index.type.isOptional {
                let count: String
                if vertex.type.isArray {
                    count = "\(vertex.identifier).count"
                } else if ["UInt", "UInt32", "Int", "Int32"].contains(vertex.type.type) {
                    count = "\(vertex.identifier)"
                } else {
                    throw SwiftEverydayShaderError("'\(vertex.identifier)' vertex must be of type Array or UInt, UInt32, Int, Int32")
                }
                return """
                if let \(index.identifier) {
                    \(try indexString(index))
                } else {
                    encoder.drawPrimitives(type: primitive, vertexStart: 0, vertexCount: \(count))
                }
                """
            } else {
                return try indexString(index)
            }
        } else if let vertex {
            let count: String
            if vertex.type.isArray {
                count = "\(vertex.identifier).count"
            } else if ["UInt32", "Int32"].contains(vertex.type.type) {
                count = "\(vertex.identifier)"
            } else {
                throw SwiftEverydayShaderError("'\(vertex.identifier)' vertex must be of type Array or UInt32, Int32")
            }
            return """
            encoder.drawPrimitives(type: primitive, vertexStart: 0, vertexCount: \(count))
            """
        } else if let index {
            return try indexString(index)
        } else if let counter {
            return """
            encoder.drawPrimitives(type: primitive, vertexStart: 0, vertexCount: \(counter.identifier))
            """
        } else {
            throw SwiftEverydayShaderError("For vertex function it is necessary to add `Buffer(vertexCount: true)` or IndexBuffer in quantity not more than one of each kind")
        }
    }
}

extension DeclarationVariable {
    var isSharedContainer: Bool {
        guard let buffer = attributes.first(where: { $0.name == "Buffer" || $0.name == "IndexBuffer" }) else {
            return false
        }
        return buffer.parameters.contains(where: { $0.label == "sharedContainer" && $0.expression == "true" })
    }
}
