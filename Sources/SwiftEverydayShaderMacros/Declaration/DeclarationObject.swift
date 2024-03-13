import SwiftSyntax
import SwiftEverydayUtils

struct DeclarationObject {
    enum DeclarationObjectType {
        case extensionDeclaration
        case structDeclaration
        case classDeclaration
    }
    let name: String
    let type: DeclarationObjectType
    let protocols: [DeclarationType]
    let syn: SyntaxProtocol
    let members: MemberBlockItemListSyntax

    static func make(_ declaration: SyntaxProtocol) throws -> DeclarationObject {
        if let obj = declaration.as(ExtensionDeclSyntax.self) {
            return .init(
                name: obj.extendedType.description.removeSpace(),
                type: .extensionDeclaration,
                protocols: try obj.inheritanceClause?.getAllList() ?? [],
                syn: declaration,
                members: obj.memberBlock.members
            )
        }
        if let obj = declaration.as(StructDeclSyntax.self) {
            return .init(
                name: obj.name.description.removeSpace(),
                type: .structDeclaration,
                protocols: try obj.inheritanceClause?.getAllList() ?? [],
                syn: declaration,
                members: obj.memberBlock.members
            )
        }
        if let obj = declaration.as(ClassDeclSyntax.self) {
            return .init(
                name: obj.name.description.removeSpace(),
                type: .classDeclaration,
                protocols: try obj.inheritanceClause?.getAllList() ?? [],
                syn: declaration,
                members: obj.memberBlock.members
            )
        }
        throw SwiftEverydayShaderError("incorect type")
    }
}

extension SyntaxProtocol {
    func getDeclarationObject() throws -> DeclarationObject {
        try DeclarationObject.make(self)
    }
}
