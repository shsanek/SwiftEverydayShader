import Metal

public protocol IFragmentFunction {
    func _prepareFragment(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws
    func prepareFragment(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws
}

public extension IFragmentFunction {
    func _prepareFragment(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws {
    }

    func prepareFragment(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws {
        try _prepareFragment(encoder: encoder, device: device)
    }
}

