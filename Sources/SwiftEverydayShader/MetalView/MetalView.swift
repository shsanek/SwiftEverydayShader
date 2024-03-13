import MetalKit
import simd
import SwiftEverydayUtils

#if canImport(UIKit)
import UIKit

public class MetalView: MTKView, MTKViewDelegate {
    private var size: CGSize = .init(width: 100, height: 100)
    public let renderQueue: ViewRenderQueue

    public init(device: MTLDevice? = nil) throws {
        let device = device ?? MTLCreateSystemDefaultDevice()
        guard let device = device else {
            throw "Device loading error"
        }
        renderQueue = .init(render: Render(device: device))
        super.init(frame: .zero, device: device)
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
            try renderQueue?.metalRender(drawable: drawable, descriptor: descriptor, size: size)
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
    private var size: CGSize = .init(width: 100, height: 100)
    public let renderQueue: ViewRenderQueue

    public init(device: MTLDevice? = nil) throws {
        let device = device ?? MTLCreateSystemDefaultDevice()
        guard let device = device else {
            throw "Device loading error"
        }
        renderQueue = .init(render: Render(device: device))
        super.init(frame: .zero, device: device)
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
            try renderQueue.metalRender(drawable: drawable, descriptor: descriptor, size: size)
        }
        catch {
            assertionFailure("\(error)")
        }
    }
}

#endif
