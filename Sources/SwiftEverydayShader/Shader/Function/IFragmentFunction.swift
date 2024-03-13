import Metal

public protocol IRootFragmentFunction {
    func _prepareFragment(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws
}

public protocol IFragmentFunction: IRootFragmentFunction {
    func prepareFragment(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws
}

public extension IFragmentFunction {
    func _prepareFragment(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws {
    }

    func prepareFragment(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws {
        try _prepareFragment(encoder: encoder, device: device)
    }
}
