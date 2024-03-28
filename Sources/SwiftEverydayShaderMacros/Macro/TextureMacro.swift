import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftEverydayUtils

public struct TextureMacro: AccessorMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingAccessorsOf declaration: some DeclSyntaxProtocol,
      in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let variable = try DeclarationVariable.make(declaration.as(VariableDeclSyntax.self))
        let containerName = containerName(for: variable)
        guard variable.type.type == "ITexture" && !variable.type.isArray else {
            throw "explicitly specify the type ITexture or ITexture"
        }
        let block: String = {
            if variable.type.isOptional {
                return """
                set {
                    \(containerName).values = newValue ?? []
                }
                get {
                    \(containerName).values.isEmpty ? nil : \(containerName).values
                }
                """
            } else {
                return """
                set {
                    \(containerName).values = [newValue]
                }
                get {
                    \(containerName).values[0]
                }
                """
            }
        }()
        return ["\(raw: block)"]
    }
}

