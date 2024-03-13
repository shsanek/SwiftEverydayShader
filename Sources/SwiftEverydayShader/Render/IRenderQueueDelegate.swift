import simd

public protocol IRenderQueueDelegate: AnyObject {
    func willRender(size: vector_float2, renderQueue: IRenderQueue) throws
    func didRender(size: vector_float2, renderQueue: IRenderQueue) throws
}

public extension IRenderQueueDelegate {
    func willRender(size: vector_float2, renderQueue: IRenderQueue) throws {
    }

    func didRender(size: vector_float2, renderQueue: IRenderQueue) throws {
    }
}
