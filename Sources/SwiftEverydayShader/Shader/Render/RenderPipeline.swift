import Metal
import SwiftEverydayUtils

public protocol IRenderPipeline {
    func render(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws
}

public final class RenderPipeline: IRenderPipeline {
    public var primitive: MTLPrimitiveType = .triangle
    public let vertexDescriptor: ShaderFunctionDescriptor<IVertexFunction>
    public let fragmentDescriptor: ShaderFunctionDescriptor<IFragmentFunction>
    private let device: MTLDevice
    private let renderState: MTLRenderPipelineState

    public init(
        vertexDescriptor: ShaderFunctionDescriptor<IVertexFunction>,
        fragmentDescriptor: ShaderFunctionDescriptor<IFragmentFunction>,
        device: MTLDevice? = nil,
        pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb,
        depthAttachmentPixelFormat: MTLPixelFormat = .depth32Float
    ) throws {
        guard let device = device ?? MTLCreateSystemDefaultDevice() else {
            throw SwiftEverydayShaderError("Metal device not found")
        }
        self.vertexDescriptor = vertexDescriptor
        self.fragmentDescriptor = fragmentDescriptor

        self.device = device

        renderState = try Self.loadPipeline(
            vertexDescriptor: vertexDescriptor,
            fragmentDescriptor: fragmentDescriptor,
            device: device,
            pixelFormat: pixelFormat,
            depthAttachmentPixelFormat: depthAttachmentPixelFormat
        )
    }

    public func render(encoder: MTLRenderCommandEncoder, device: MTLDevice) throws {
        guard vertexDescriptor.function.readyForRendering else {
            return
        }
        encoder.setRenderPipelineState(renderState)
        try fragmentDescriptor.function.prepareFragment(encoder: encoder, device: device)
        try vertexDescriptor.function.render(encoder: encoder, device: device, primitive: primitive)
    }
}

extension RenderPipeline {
    private static var pipelineStateCash = [String: MTLRenderPipelineState]()
    private static func loadPipeline(
        vertexDescriptor: ShaderFunctionDescriptor<IVertexFunction>,
        fragmentDescriptor: ShaderFunctionDescriptor<IFragmentFunction>,
        device: MTLDevice,
        pixelFormat: MTLPixelFormat,
        depthAttachmentPixelFormat: MTLPixelFormat
    ) throws -> MTLRenderPipelineState {
        let id = "v:\(vertexDescriptor.id)_f\(fragmentDescriptor.id)"
        if let state = pipelineStateCash[id] {
            return state
        }
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = UUID().uuidString
        pipelineStateDescriptor.vertexFunction = vertexDescriptor.metalFunction
        pipelineStateDescriptor.fragmentFunction = fragmentDescriptor.metalFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = depthAttachmentPixelFormat
        let state = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        pipelineStateCash[id] = state
        return state
    }
}
