import Metal

public protocol IVertexFunction {
    var _readyForRendering: Bool { get }
    func _render(encoder: MTLRenderCommandEncoder, device: MTLDevice, primitive: MTLPrimitiveType) throws
    func _prepare(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws

    var readyForRendering: Bool { get }
    func render(encoder: MTLRenderCommandEncoder, device: MTLDevice, primitive: MTLPrimitiveType) throws
}

public extension IVertexFunction {
    func _render(encoder: MTLRenderCommandEncoder, device: MTLDevice, primitive: MTLPrimitiveType) throws {
    }

    func _prepare(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws {
    }

    var _readyForRendering: Bool { true }

    var readyForRendering: Bool { _readyForRendering }

    func render(encoder: MTLRenderCommandEncoder, device: MTLDevice, primitive: MTLPrimitiveType) throws {
        try _prepare(encoder: encoder, device: device)
        try _render(encoder: encoder, device: device, primitive: primitive)
    }
}
