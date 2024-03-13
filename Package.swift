// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftEverydayShader",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "SwiftEverydayShader",
            targets: ["SwiftEverydayShader"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
        .swiftEveryday("SwiftEverydayUtils"),
        .swiftEveryday("SwiftEverydayApp"),
        .swiftEveryday("SwiftEverydayTestsUtils")
    ],
    targets: [
        .macro(
            name: "SwiftEverydayShaderMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "SwiftEverydayUtils"
            ]
        ),
        .executableTarget(
            name: "SwiftEverydayShaderExample",
            dependencies: ["SwiftEverydayUtils", "SwiftEverydayShader", "SwiftEverydayApp"]
        ),
        .target(
            name: "SwiftEverydayShader",
            dependencies: ["SwiftEverydayUtils", "SwiftEverydayShaderMacros"]
        ),
        .testTarget(
            name: "SwiftEverydayShaderMacrosTests",
            dependencies: [
                "SwiftEverydayShaderMacros",
                "SwiftEverydayUtils",
                "SwiftEverydayTestsUtils",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            resources: [.copy("Resources")]
        ),
    ]
)

extension Package.Dependency {
    enum Source {
        case version(Version)
        case branch(name: String)
    }
    static let swiftEverydaySource: Source = .branch(name: "master")

    static func swiftEveryday(_ name: String) -> Package.Dependency {
        let file = #file
        let url = URL(filePath: file).deletingLastPathComponent().deletingLastPathComponent()
        if url.lastPathComponent == "SwiftEverydayProject" {
            return .package(name: name, path: "../\(name)")
        } else {
            switch swiftEverydaySource {
            case .version(let version):
                return .package(url: "https://github.com/shsanek/\(name).git", exact: version)
            case .branch(let name):
                return .package(url: "https://github.com/shsanek/\(name).git", branch: name)
            }
        }
    }
}
