import SwiftSyntax
import SwiftEverydayUtils

struct DeclarationVariable {
    let identifier: String
    let type: DeclarationType
    let attributes: [Attribute]
    let initializer: String?
    let key: String

    struct Attribute {
        struct AttributeParameter {
            let label: String?
            let expression: String
        }
        let name: String
        let parameters: [AttributeParameter]
    }

    static func make(_ item: MemberBlockItemSyntax) throws -> DeclarationVariable {
        return try make(item.decl.as(VariableDeclSyntax.self))
    }

    static func make(_ variable: VariableDeclSyntax?) throws -> DeclarationVariable {
        guard
            let variable,
            let identifier = variable.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            throw SwiftEverydayShaderError("")
        }
        let attributes: [Attribute] = variable.attributes.compactMap({ $0.as(AttributeSyntax.self) }).map { attribute in
            let name = attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text ?? ""
            let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) ?? []
            let parameters: [Attribute.AttributeParameter] = arguments.map({
                .init(
                    label: $0.label?.text,
                    expression: $0.expression.description
                )
            })
            return Attribute(name: name, parameters: parameters)
        }

        let initializer = variable.bindings.first?.initializer?.value.description
        return .init(
            identifier: identifier.text,
            type: try (variable.bindings.first?.typeAnnotation?.type.getDeclarationType()).noOptional(),
            attributes: attributes,
            initializer: initializer,
            key: identifier.text
        )
    }
}
