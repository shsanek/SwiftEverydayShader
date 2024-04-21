import Metal
import SwiftEverydayUtils

public class MetalBufferCache {
    private var isNeedUpdate: Bool = true
    private var cache: MTLBuffer?

    func getBuffer<T: RawEncodable>(_ array: [T], device: MTLDevice) throws -> MTLBuffer? {
        var buffer: MTLBuffer?
        if let buffer = cache, !isNeedUpdate {
            return buffer
        }
        if array.count == 0 {
            return nil
        }
        try UnsafePointerRawEncoder.encode(object: array) { pointer in
            if let pointer = pointer {
                buffer = try getMTLBuffer(
                    bytes: pointer,
                    length: MemoryLayout<T>.stride * array.count,
                    device: device
                )
            }
        }
        isNeedUpdate = false
        return buffer
    }

    func setNeedUpdate() {
        isNeedUpdate = true
    }

    public func getMTLBuffer(bytes pointer: UnsafeRawPointer, length: Int, device: MTLDevice) throws -> MTLBuffer {
        if let cached = self.cache, cached.length == length {
            cached.contents().copyMemory(from: pointer, byteCount: length)
            return cached
        }
        guard let newBuff = device.makeBuffer(
            bytes: pointer,
            length: length,
            options: [MTLResourceOptions.storageModeShared]
        ) else {
            throw "can't create buffer"
        }
        self.cache = newBuff
        return newBuff
    }
}
