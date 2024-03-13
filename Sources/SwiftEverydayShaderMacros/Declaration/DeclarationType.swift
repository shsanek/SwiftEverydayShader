import SwiftSyntax
import SwiftEverydayUtils
final class DeclarationType {
    var type: String
    var isArray: Bool = false
    var isOptional: Bool = false
    var subTypes: [DeclarationType]

    init(type: String, subTypes: [DeclarationType]) {
        self.type = type
        self.subTypes = subTypes
    }

    var fullNoOptionName: String {
        var result = type
        if !subTypes.isEmpty {
            result += "<\(subTypes.map { $0.fullName }.joined(separator: ","))>"
        }
        return result
    }

    var fullName: String {
        if isOptional {
            return fullNoOptionName + "?"
        } else {
            return fullNoOptionName
        }
    }

    private static func makeNotOptionalFullType(_ type: TypeSyntax?) throws -> DeclarationType {
        if let array = try makeArrayType(type) {
            return array
        }
        guard let type = type?.as(IdentifierTypeSyntax.self) else {
            throw SwiftEverydayShaderError("Type annotation not found")
        }
        let subtypes = try type.genericArgumentClause?.arguments.map { try makeFullType($0.argument) } ?? []
        return .init(type: type.name.text, subTypes: subtypes)
    }

    private static func makeArrayType(_ type: TypeSyntax?) throws -> DeclarationType? {
        guard let type = type?.as(ArrayTypeSyntax.self) else {
            return nil
        }
        let elementType = try makeFullType(type.element)
        elementType.isArray = true
        return elementType
    }

    static func makeFullType(_ type: TypeSyntax?) throws -> DeclarationType {
        if let type = type?.as(OptionalTypeSyntax.self) {
            let type = try makeNotOptionalFullType(type.wrappedType)
            type.isOptional = true
            return type
        } else {
            return try makeNotOptionalFullType(type)
        }
    }
}

extension SyntaxProtocol {
    func getDeclarationType() throws -> DeclarationType {
        guard let obj = self.as(TypeSyntax.self) else {
            throw SwiftEverydayShaderError("'\(type(of: self))' is not 'TypeSyntax'")
        }
        return try DeclarationType.makeFullType(obj)
    }
}

extension InheritanceClauseSyntax {
    func getAllList() throws -> [DeclarationType] {
        try inheritedTypes.map({ try $0.type.getDeclarationType() })
    }
}
