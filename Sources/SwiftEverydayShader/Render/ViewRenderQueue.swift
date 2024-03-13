import Foundation
import simd
import SwiftEverydayUtils
import MetalKit

public final class ViewRenderQueue: IRenderQueue {
    public weak var delegate: IRenderQueueDelegate?

    private var task: RenderTask?
    private let render: Render

    init(render: Render) {
        self.render = render
    }

    public func addTask(_ task: RenderTask) throws {
        self.task = task
    }

    func metalRender(
        drawable: CAMetalDrawable?,
        descriptor: MTLRenderPassDescriptor,
        size: vector_float2
    ) throws {
        try delegate?.willRender(size: size, renderQueue: self)
        guard let task else {
            return
        }
        self.task = nil
        try render.metalRender(drawable: drawable, descriptor: descriptor, size: size, task: task)
        try delegate?.didRender(size: size, renderQueue: self)
    }
}
