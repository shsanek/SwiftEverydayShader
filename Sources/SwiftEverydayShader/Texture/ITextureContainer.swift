import Foundation
import MetalKit
import SwiftEverydayUtils

public struct TextureInfo {
    public let width: Int
    public let height: Int
    public let pixelFormat: PixelFormat

    public let data: () throws -> [UInt8]?
}

public protocol ITexture {
    func getTexture(for device: MTLDevice) throws -> MTLTexture?
}

public final class EmptyTexture: ITexture {
    public init() { }
    public func getTexture(for device: MTLDevice) throws -> MTLTexture? {
        return nil
    }
}

public final class TextureContainer: ITexture {
    public var loadTextureInfo: (() throws -> TextureInfo)? {
        didSet {
            isNeedLoad = true
        }
    }
    public private(set) var mtlTexture: MTLTexture?
    private var isNeedLoad: Bool = true

    public init(loadTextureInfo: (() throws -> TextureInfo)? = nil) {
        self.loadTextureInfo = loadTextureInfo
    }

    public init(_ textureInfo: TextureInfo) {
        self.loadTextureInfo = { textureInfo }
    }

    public func loadIfNeeded(for device: MTLDevice) throws {
        guard isNeedLoad else {
            return
        }
        isNeedLoad = true
        guard let info = try loadTextureInfo?() else {
            return
        }
        loadTextureInfo = nil
        let description = MTLTextureDescriptor()
        description.pixelFormat = info.pixelFormat.mtlPixelFormat
        description.height = info.height
        description.width = info.width
        description.usage = .shaderRead
        guard let result = device.makeTexture(descriptor: description) else {
            throw "Texture not created"
        }
        if var data = try info.data() {
            result.replace(
                region: .init(
                    origin: .init(x: 0, y: 0, z: 0),
                    size: .init(width: info.width, height: info.height, depth: 1)
                ),
                mipmapLevel: 0,
                withBytes: &data,
                bytesPerRow: info.width * 4
            )
        }
        mtlTexture = result
    }

    public func getTexture(for device: MTLDevice) throws -> MTLTexture? {
        try loadIfNeeded(for: device)
        return mtlTexture
    }
}
