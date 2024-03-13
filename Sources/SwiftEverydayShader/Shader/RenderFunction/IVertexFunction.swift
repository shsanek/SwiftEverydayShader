import Metal

public protocol IRootVertexFunction {
    var _readyForRendering: Bool { get }
    func _render(encoder: MTLRenderCommandEncoder, device: MTLDevice, primitive: MTLPrimitiveType) throws
}

public protocol IVertexFunction: IRootVertexFunction {
    var readyForRendering: Bool { get }
    func render(encoder: MTLRenderCommandEncoder, device: MTLDevice, primitive: MTLPrimitiveType) throws
}

public extension IVertexFunction {
    func _render(encoder: MTLRenderCommandEncoder, device: MTLDevice, primitive: MTLPrimitiveType) throws {
    }

    var _readyForRendering: Bool { true }

    var readyForRendering: Bool { _readyForRendering }
    func render(encoder: MTLRenderCommandEncoder, device: MTLDevice, primitive: MTLPrimitiveType) throws {
        try _render(encoder: encoder, device: device, primitive: primitive)
    }
}
