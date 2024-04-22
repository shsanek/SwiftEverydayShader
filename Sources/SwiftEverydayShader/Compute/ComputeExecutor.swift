import MetalKit
import simd
import SwiftEverydayUtils

public final class ComputeExecutor {
    private let commandQueue: MTLCommandQueue?
    private let device: MTLDevice

    public static let global = MTLCreateSystemDefaultDevice().flatMap { ComputeExecutor(device: $0) }

    public init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
    }

    public init(device: MTLDevice, queue: MTLCommandQueue) {
        self.device = device
        self.commandQueue = queue
    }

    public func run(task: ComputeTask) throws {
        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            throw "Not create ComputeEncoder"
        }
        for pipeline in task.pipelines.wrappedValue {
            try pipeline.run(encoder: computeEncoder, device: device)
        }
        computeEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    public func run(_ pipeline: ComputePipeline) throws {
        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            throw "Not create ComputeEncoder"
        }
        try pipeline.run(encoder: computeEncoder, device: device)

        computeEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
