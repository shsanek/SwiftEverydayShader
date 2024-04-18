import Metal

public protocol IComputeFunction {
    func _prepareCompute(encoder: MTLComputeCommandEncoder, device: MTLDevice) throws
    func prepareCompute(encoder: MTLComputeCommandEncoder, device: MTLDevice) throws
    func runCompute(encoder: MTLComputeCommandEncoder, device: MTLDevice, maxTotalThreadsPerThreadgroup: Int) throws
}

public extension IComputeFunction {
    func _prepareCompute(encoder: MTLComputeCommandEncoder, device: MTLDevice) throws {

    }

    func prepareCompute(encoder: MTLComputeCommandEncoder, device: MTLDevice) throws {
        try _prepareCompute(encoder: encoder, device: device)
    }
}

