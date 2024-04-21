import XCTest

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftSyntaxMacroExpansion
import SwiftSyntax

import SwiftEverydayShaderMacros
import SwiftEverydayTestsUtils
import SwiftEverydayUtils

extension XCTestCase {
    func checkFile(_ name: String) throws {
        let fileURL = Bundle.module.url(forResource: name, withExtension: "txt", subdirectory: "Resources")
        guard let fileURL else {
            throw SwiftEverydayShaderError("Not open file for test")
        }
        let content = try Data(contentsOf: fileURL)
        guard let string = String(data: content, encoding: .utf8) else {
            throw SwiftEverydayShaderError("Not open file for test")
        }
        let tests = string
            .components(separatedBy: "\n")
            .enumerated()
            .map({ "\($0.offset)___###___\($0.element)" })
            .joined(separator: "\n")
            .components(separatedBy: "--->\n")
            .map({ removeTrashFromString($0) })
            .filter({ !$0.isEmpty })
        for test in tests {
            let part = test.components(separatedBy: "---\n")
            guard part.count == 2 else {
                continue
            }
            try check(
                input: part[0].components(separatedBy: "\n").compactMap({ $0.components(separatedBy: "___###___").last }).joined(separator: "\n"),
                output: part[1],
                fileName: "\(name).txt"
            )
        }
    }

    func check(input: String, output: String, fileName: String) throws {
        let source: SourceFileSyntax = "\(raw: input)"

        let file = BasicMacroExpansionContext.KnownSourceFile(
            moduleName: "MyModule",
            fullFilePath: "test.swift"
        )


        let context = BasicMacroExpansionContext(sourceFiles: [source: file])

        let transformedSF = source.expand(
            macros:[
                "Shader": ShaderMacro.self,
                "Buffer": BufferMacro.self,
                "IndexBuffer": BufferMacro.self,
            ],
            in: context
        )

        let result = removeTrashFromString(transformedSF.description).components(separatedBy: "\n")
        let target = removeTrashFromString(output).components(separatedBy: "\n")

        let path: String = #file
        let url = URL(filePath: path).deletingLastPathComponent().appending(path: "Resources/\(fileName)")
        let count = min(result.count, target.count)

        for i in 0..<count {
            let part = target[i].components(separatedBy: "___###___")
            guard part.count == 2, let line = Int(part[0]) else {
                throw SwiftEverydayShaderError("Incorect line format")
            }
            if part[1] != result[i] {
                SETAssert(self, url.path(), UInt32(line + 1), "'\(part[1])' != '\(result[i])'")
            }
        }

        if result.count != target.count {
            let part = target.last?.components(separatedBy: "___###___").first
            let value = Int(part ?? "0") ?? 0

            SETAssert(self, url.path(), UInt32(value), "Error in next line")
        }
    }

    func removeTrashFromString(_ string: String) -> String {
        string
            .components(separatedBy: "\t").filter({ !$0.isEmpty }).joined()
            .components(separatedBy: " ").filter({ !$0.isEmpty }).joined(separator: " ")
            .components(separatedBy: "\n").compactMap({
                ($0.components(separatedBy: "___###___").last?
                    .components(separatedBy: " ")
                    .filter({ !$0.isEmpty })
                    .joined() ?? "" == ""
                ) ? nil : $0
            }).joined(separator: "\n")
    }
}
