import MetalKit
import simd
import SwiftEverydayUtils

final class Render {
    private let commandQueue: MTLCommandQueue?
    private let device: MTLDevice

    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
    }

    func metalRender(
        drawable: CAMetalDrawable?,
        descriptor: MTLRenderPassDescriptor,
        size: vector_float2,
        pipelines: ValueContainer<[IRenderPipeline]>
    ) throws {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .lessEqual
        depthDescriptor.isDepthWriteEnabled = true

        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)

        guard
            let commandQueue = commandQueue,
            let buffer = commandQueue.makeCommandBuffer(),
            let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor),
            let depthState = device.makeDepthStencilState(descriptor: depthDescriptor)
        else {
            return
        }

        encoder.setDepthStencilState(depthState)
        encoder.setFrontFacing(.clockwise)
        encoder.setCullMode(.back)

        buffer.label = UUID().uuidString

        let viewPort = MTLViewport(
            originX: 0,
            originY: 0,
            width: Double(size.x),
            height: Double(size.y),
            znear: -1,
            zfar: 1
        )

        encoder.setViewport(viewPort)

        var outputError: Error?
        do {
            try pipelines.wrappedValue.forEach({ try $0.render(encoder: encoder, device: device) })
        }
        catch {
            outputError = error
        }

        encoder.endEncoding()
        drawable.flatMap { buffer.present($0) }
        buffer.commit()

        if let error = outputError {
            throw error
        }
    }
}
