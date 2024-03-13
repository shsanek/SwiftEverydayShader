import SwiftEverydayApp
import SwiftEverydayShader
import simd
import SwiftEverydayUtils
import Metal

struct VertexInputItem: RawEncodable {
    let position: vector_float2
    let color: vector_float3

    init(position: vector_float2, color: vector_float3) {
        self.position = position
        self.color = color
    }
}

@Shader
final class SpriteVertexFunction: IVertexFunction {
    @VertexBuffer(0) var items: [VertexInputItem]
}

@Shader
final class SpriteFragmentFunction: IFragmentFunction {
}

final class RenderLoop: IViewRenderLoop {
    @ValueContainer var pipelines: [IRenderPipeline]

    init(_ pipelines: [IRenderPipeline]) {
        self.pipelines = pipelines
    }

    func render(size: vector_float2, render: (ValueContainer<[IRenderPipeline]>) throws -> Void) throws {
        try render(_pipelines)
    }
}

let function = SpriteVertexFunction()

let pipeLine = try! RenderPipeline(
    vertexDescriptor: .load("spriteVertexShader", bundle: .module, function: function),
    fragmentDescriptor: .load("spriteFragmentShader", bundle: .module, function: SpriteFragmentFunction())
)

function.items = [
    VertexInputItem(position: .init(-1, -1), color: .init(1, 0, 0)),
    VertexInputItem(position: .init(-1, 1), color: .init(0, 1, 0)),
    VertexInputItem(position: .init(1, -1), color: .init(1, 0, 0)),

    VertexInputItem(position: .init(1, -1), color: .init(1, 0, 0)),
    VertexInputItem(position: .init(-1, 1), color: .init(0, 1, 0)),
    VertexInputItem(position: .init(1, 1), color: .init(0, 0, 1)),

    VertexInputItem(position: .init(-0.5, -0.5), color: .init(0, 0, 1)),
    VertexInputItem(position: .init(-0.5, 0.5), color: .init(0, 0, 1)),
    VertexInputItem(position: .init(0.5, -0.5), color: .init(0, 0, 1)),

    VertexInputItem(position: .init(0.5, -0.5), color: .init(0, 0, 1)),
    VertexInputItem(position: .init(-0.5, 0.5), color: .init(0, 0, 1)),
    VertexInputItem(position: .init(0.5, 0.5), color: .init(0, 0, 1))
]

App({
    MetalView(loop: RenderLoop([pipeLine]))
}).run()
