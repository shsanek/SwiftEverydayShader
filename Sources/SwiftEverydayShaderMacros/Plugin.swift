import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct EditableMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ShaderMacro.self,
        BufferMacro.self,
        EmptyAccessorMacro.self,
    ]
}
