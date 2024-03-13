import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftEverydayUtils

public struct BufferMacro: AccessorMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingAccessorsOf declaration: some DeclSyntaxProtocol,
      in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let variable = try DeclarationVariable.make(declaration.as(VariableDeclSyntax.self))
        let containerName = containerName(for: variable)
        let block: String = {
            if variable.type.isArray && variable.type.isOptional {
                return """
                set {
                    \(containerName).values = newValue ?? []
                }
                get {
                    \(containerName).values.isEmpty ? nil : \(containerName).values
                }
                """
            } else if variable.type.isOptional  {
                return """
                set {
                    \(containerName).values = newValue.flatMap { [$0] } ?? []
                }
                get {
                    \(containerName).values.first
                }
                """
            } else if variable.type.isArray {
                return """
                set {
                    \(containerName).values = newValue
                }
                get {
                    \(containerName).values
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

