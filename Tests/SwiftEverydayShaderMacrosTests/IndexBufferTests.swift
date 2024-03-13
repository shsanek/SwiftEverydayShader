import XCTest
import SwiftEverydayUtils

final class IndexBufferTests: XCTestCase {
    func test01() throws {
        try checkFile("IndexBufferTests/TestMacro1")
    }

    func test02() throws {
        try checkFile("IndexBufferTests/TestMacro2")
    }

    func test03() throws {
        try checkFile("IndexBufferTests/TestMacro3")
    }

    func test04() throws {
        try checkFile("IndexBufferTests/TestMacro4")
    }
}
