import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftEverydayUtils

func containerName(for variable: DeclarationVariable) -> String {
    return "_\(variable.identifier)BufferContainer"
}

func textureName(for variable: DeclarationVariable) -> String {
    return "_\(variable.identifier)TextureContainer"
}

public struct ShaderMacro: MemberMacro {
    enum ShaderType {
        static let vertex = "IVertexFunction"
        static let fragment = "IFragmentFunction"
        static let rootVertex = "IRootVertexFunction"
        static let rootFragment = "IRootFragmentFunction"
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let allVariables = declaration
            .memberBlock
            .members
            .compactMap({ try? DeclarationVariable.make($0) })
        let variables = allVariables.filter({
            $0.attributes.contains {
                $0.name == "Buffer" ||
                $0.name == "IndexBuffer" ||
                $0.name == "VertexBuffer"
            }
        })

        let counter = allVariables.filter({
            $0.attributes.contains {
                $0.name == "VertexCount"
            }
        })

        let protocols = declaration.inheritanceClause?.inheritedTypes.map({ $0.type.description.removeSpace() }) ?? []

        let isVertexShader = protocols.contains(where: { value in [ShaderType.rootVertex, ShaderType.vertex].contains(value) })
        let isFragmentShader = protocols.contains(where: { value in [ShaderType.fragment, ShaderType.rootFragment].contains(value) })


        let containers = variables.map({ makeBufferContainer($0) })

        var functions: [DeclSyntax] = []
        if isVertexShader {
            let vertexBuffer = variables.filter({ $0.attributes.contains { $0.name == "VertexBuffer" } })
            let indexBuffer = variables.filter({ $0.attributes.contains { $0.name == "IndexBuffer" } })
            guard
                ((vertexBuffer.count + indexBuffer.count) > 0 &&
                indexBuffer.count < 2 &&
                vertexBuffer.count < 2) ||
                (vertexBuffer.count + indexBuffer.count == 0 && counter.count == 1)
            else
            {
                throw SwiftEverydayShaderError("For vertex function it is necessary to add VertexBuffer or IndexBuffer in quantity not more than one of each kind or one VertexCount")
            }
            let components = try variables.map({ try vertexFunctionComponent($0) }).joined(separator: "\n")

            functions.append("""
            var _readyForRendering: Bool {
                \(raw: try readyForRenderingVertexFunction(vertex: vertexBuffer.first, index: indexBuffer.first, counter: counter.first))
            }
            func _render(encoder: MTLRenderCommandEncoder, device: MTLDevice, primitive: MTLPrimitiveType) throws {
                \(raw: components)
                \(raw: try renderVertexFunction(vertex: vertexBuffer.first, index: indexBuffer.first, counter: counter.first))
            }
            """)
        }

        if isFragmentShader {
            let components = try variables.map({ try fragmentFunctionComponent($0) }).joined(separator: "\n")
            functions.append("""
            func _prepareFragment(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws {
                \(raw: components)
            }
            """)
        }

        return
            containers + functions
    }

    static func makeBufferContainer(_ variable: DeclarationVariable) -> DeclSyntax {
        if variable.isSharedContainer {
            "public var \(raw: containerName(for: variable)): BufferContainer<\(raw: variable.type.type)> = .init(\(raw: variable.initializer ?? ""))"
        } else {
            "private var \(raw: containerName(for: variable)): BufferContainer<\(raw: variable.type.type)> = .init(\(raw: variable.initializer ?? ""))"
        }
    }

    static func fragmentFunctionComponent(_ variable: DeclarationVariable) throws -> String {
        guard
            let buffer = variable.attributes.first(where: { $0.name == "Buffer" || $0.name == "VertexBuffer" }),
            let index = buffer.parameters.last(where: { $0.label == nil || $0.label == "fragmentIndex" })
        else {
            return ""
        }
        if buffer.name == "VertexBuffer" && index.label == nil {
            return ""
        }
        return "try encoder.setFragmentBuffer(\(containerName(for: variable)).getBuffer(for: device), offset: 0, index: \(index.expression))"
    }

    static func vertexFunctionComponent(_ variable: DeclarationVariable) throws -> String {
        guard
            let buffer = variable.attributes.first(where: { $0.name == "Buffer" || $0.name == "VertexBuffer" }),
            let index = buffer.parameters.last(where: { $0.label == nil || $0.label == "vertexIndex" })?.expression
        else {
            return ""
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
            throw SwiftEverydayShaderError("For vertex function it is necessary to add VertexBuffer or IndexBuffer in quantity not more than one of each kind")
        }
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
                return """
                if let \(index.identifier) {
                    \(try indexString(index))
                } else {
                    encoder.drawPrimitives(type: primitive, vertexStart: 0, vertexCount: \(vertex.identifier).count)
                }
                """
            } else {
                return try indexString(index)
            }
        } else if let vertex {
            guard vertex.type.isArray else {
                throw SwiftEverydayShaderError("vertex must be of type Array")
            }
            return """
            encoder.drawPrimitives(type: primitive, vertexStart: 0, vertexCount: \(vertex.identifier).count)
            """
        } else if let index {
            return try indexString(index)
        } else if let counter {
            return """
            encoder.drawPrimitives(type: primitive, vertexStart: 0, vertexCount: \(counter.identifier))
            """
        } else {
            throw SwiftEverydayShaderError("For vertex function it is necessary to add VertexBuffer or IndexBuffer in quantity not more than one of each kind")
        }
    }
}

extension DeclarationVariable {
    var isSharedContainer: Bool {
        guard let buffer = attributes.first(where: { $0.name == "Buffer" || $0.name == "VertexBuffer" || $0.name == "IndexBuffer" }) else {
            return false
        }
        return buffer.parameters.contains(where: { $0.label == "sharedContainer" && $0.expression == "true" })
    }
}
