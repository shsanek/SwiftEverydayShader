import SwiftEverydayShader
import simd
import Metal

@Shader
final class LifeComputeFunction: IComputeFunction {
    @Buffer(0, sharedContainer: true) var new: [UInt8] = .init(repeating: .random(in: 0...1), count: 100 * 100)
    @Buffer(1) private var old: [UInt8] = .init(repeating: .random(in: 0...1), count: 100 * 100)
    @Buffer(2, sharedContainer: true) var size: vector_int2 = .init(100, 100)

    private func swipe() {
        let tmp = _newBufferContainer
        _newBufferContainer = _oldBufferContainer
        _oldBufferContainer = tmp
    }

    func runCompute(encoder: MTLComputeCommandEncoder, device: MTLDevice, maxTotalThreadsPerThreadgroup: Int) throws {
        swipe()
        try prepareCompute(encoder: encoder, device: device)
        let count = Int(size.x * size.y)
        let gridSize = MTLSize(width: Int(size.x), height: Int(size.y), depth: 1)
        var threadGroupSize = maxTotalThreadsPerThreadgroup
        if threadGroupSize > count {
            threadGroupSize = count
        }
        let threadsPerThreadgroup = MTLSize(width: threadGroupSize, height: 1, depth: 1)
        encoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadsPerThreadgroup)
    }

    func update(_ size: vector_int2) {
        self.size = size
        let length = Int(size.x * size.y)
        var array: [UInt8] = .init(repeating: 0, count: length)
        for i in 0..<length {
            array[i] = .random(in: 0...1)
        }
        new = array
        old = array
    }
}

@Shader
final class LifeVertexFunction: IVertexFunction {
    @Buffer(0, vertexCount: true) var items: [TextureInputItem]
}

@Shader
final class LifeFragmentFunction: IFragmentFunction {
    @Buffer(0, sharedContainer: true) var items: [UInt8] = []
    @Buffer(1, sharedContainer: true) var size: vector_int2 = .init(100, 100)
}
