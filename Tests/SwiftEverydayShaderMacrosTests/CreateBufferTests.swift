import XCTest
import SwiftEverydayUtils

final class CreateBufferTests: XCTestCase {
    func test01() throws {
        try checkFile("CreateBufferTests/TestMacro1")
    }

    func test02() throws {
        try checkFile("CreateBufferTests/TestMacro2")
    }

    func test03() throws {
        try checkFile("CreateBufferTests/TestMacro3")
    }

    func test04() throws {
        try checkFile("CreateBufferTests/TestMacro4")
    }
}
