import Foundation
import MetalKit
import SwiftEverydayUtils

public struct TextureInfo {
    public let width: Int
    public let height: Int
    public let pixelFormat: PixelFormat

    public let data: () throws -> [UInt8]?
}

public final class TextureContainer {
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

public extension TextureInfo {
    static func load(with image: CGImage, pixelFormat: PixelFormat) throws -> TextureInfo {
        let height = image.height
        let width = image.width

        let pixelCount = width * height

        let mutBufPtr = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: pixelCount * 4)

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bitmapInfo =
            CGBitmapInfo.byteOrder32Big.rawValue |
            CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue

        let context = CGContext(
            data: mutBufPtr.baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )

        context?.draw(image, in: .init(x: 0, y: 0, width: width, height: height))
        var result: [UInt8] = Array(repeating: 0x00, count: pixelCount * 4)
        DispatchQueue.concurrentPerform(iterations: pixelCount) { i in
            let j = i * 4
            let r = mutBufPtr[j + 0]
            let g = mutBufPtr[j + 1]
            let b = mutBufPtr[j + 2]
            let a = mutBufPtr[j + 3]
            result[pixelCount * 4 - 1 - (j + 0)] = a
            result[pixelCount * 4 - 1 - (j + 1)] = r
            result[pixelCount * 4 - 1 - (j + 2)] = g
            result[pixelCount * 4 - 1 - (j + 3)] = b
        }
        mutBufPtr.deallocate()
        return .init(width: width, height: height, pixelFormat: pixelFormat, data: {
            result
        })
    }

    static func load(file: String, bundle: Bundle, pixelFormat: PixelFormat = .rgba) throws -> TextureInfo {
        guard let url = bundle.url(forResource: file, withExtension: "") else {
            throw "Not load file \(file)"
        }
        return try load(data: try Data(contentsOf: url), pixelFormat: pixelFormat)
    }
}

#if canImport(UIKit)
import UIKit

public extension TextureInfo {
    static func load(image name: String, pixelFormat: PixelFormat = .rgba) throws -> TextureInfo {
        guard let image = UIImage(named: name)?.cgImage else {
            throw "Image not load"
        }
        return try load(with: image, device: device, pixelFormat: pixelFormat)
    }

    static func load(data: Data, pixelFormat: PixelFormat = .rgba) throws -> TextureInfo {
        guard let image = UIImage(data: data)?.cgImage else {
            throw "Not load cgImage"
        }
        return try load(with: image, device: device, pixelFormat: pixelFormat)
    }
}

#endif

#if canImport(Cocoa)
import Cocoa

public extension TextureInfo {
    static func load(data: Data, pixelFormat: PixelFormat = .rgba) throws -> TextureInfo {
        guard let image = NSImage(data: data)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw "Not load cgImage"
        }
        return try load(with: image, pixelFormat: pixelFormat)
    }
}

#endif

