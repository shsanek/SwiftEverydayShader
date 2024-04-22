import Metal
import SwiftEverydayUtils

public final class ComputePipeline {
    public let computeDescriptor: ShaderFunctionDescriptor<IComputeFunction>
    private let device: MTLDevice
    private let computeState: MTLComputePipelineState

    public init(
        computeDescriptor: ShaderFunctionDescriptor<IComputeFunction>,
        device: MTLDevice? = nil
    ) throws {
        guard let device = device ?? MTLCreateSystemDefaultDevice() else {
            throw SwiftEverydayShaderError("Metal device not found")
        }
        self.computeDescriptor = computeDescriptor

        self.device = device

        computeState = try Self.loadPipeline(computeDescriptor: computeDescriptor, device: device)
    }

    public func run(encoder: MTLComputeCommandEncoder, device: MTLDevice) throws {
        encoder.setComputePipelineState(computeState)
        try computeDescriptor.function.runCompute(
            encoder: encoder,
            device: device,
            maxTotalThreadsPerThreadgroup: computeState.maxTotalThreadsPerThreadgroup
        )
    }
}

extension ComputePipeline {
    private static var pipelineStateCash = [String: MTLComputePipelineState]()
    private static func loadPipeline(
        computeDescriptor: ShaderFunctionDescriptor<IComputeFunction>,
        device: MTLDevice
    ) throws -> MTLComputePipelineState {
        let id = "c:\(computeDescriptor.id)"
        if let state = pipelineStateCash[id] {
            return state
        }
        let state = try device.makeComputePipelineState(function: computeDescriptor.metalFunction)
        pipelineStateCash[id] = state
        return state
    }
}

