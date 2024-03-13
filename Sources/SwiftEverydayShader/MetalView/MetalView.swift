import MetalKit
import simd
import SwiftEverydayUtils

public protocol IViewRenderLoop {
    func render(size: vector_float2, render: (ValueContainer<[IRenderPipeline]>) throws -> Void) throws
}

#if canImport(UIKit)
import UIKit

public class MetalView: MTKView, MTKViewDelegate {
    private var render: Render?
    private var size: CGSize = .init(width: 100, height: 100)
    private let loop: IViewRenderLoop

    public init(loop: IViewRenderLoop) {
        self.loop = loop
        super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        guard let defaultDevice = device else {
            fatalError("Device loading error")
        }
        render = Render(device: defaultDevice)
        colorPixelFormat = .bgra8Unorm_srgb
        depthStencilPixelFormat = .depth32Float
        clearDepth = 1
        self.delegate = self
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.size = size
    }

    public func draw(in view: MTKView) {
        do {
            let size = vector_float2(Float32(size.width), Float32(size.height))
            guard
                let descriptor = view.currentRenderPassDescriptor,
                let drawable = view.currentDrawable
            else {
                return
            }
            try loop.render(size: size) { container in
                try render?.metalRender(drawable: drawable, descriptor: descriptor, size: size, pipelines: container)
            }

        }
        catch {
            assertionFailure("\(error)")
        }
    }
}

#endif

#if canImport(Cocoa)
import Cocoa

public class MetalView: MTKView, MTKViewDelegate {
    private var render: Render?
    private var size: CGSize = .init(width: 100, height: 100)
    private let loop: IViewRenderLoop

    public init(loop: IViewRenderLoop) {
        self.loop = loop
        super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        guard let defaultDevice = device else {
            fatalError("Device loading error")
        }
        render = Render(device: defaultDevice)
        colorPixelFormat = .bgra8Unorm_srgb
        depthStencilPixelFormat = .depth32Float
        clearDepth = 1
        self.delegate = self
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.size = size
    }

    public func draw(in view: MTKView) {
        do {
            let size = vector_float2(Float32(size.width), Float32(size.height))
            guard
                let descriptor = view.currentRenderPassDescriptor,
                let drawable = view.currentDrawable
            else {
                return
            }
            try loop.render(size: size) { container in
                try render?.metalRender(drawable: drawable, descriptor: descriptor, size: size, pipelines: container)
            }

        }
        catch {
            assertionFailure("\(error)")
        }
    }
}

#endif
