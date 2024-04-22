import SwiftEverydayShader
import SwiftEverydayUtils
import simd

final class TextureExample: BaseExample, IExample {
    private let vertexFunction = TextureVertexFunction()
    private let fragmentFunction = TextureFragmentFunction()

    func load(size: vector_float2, queue: IRenderQueue) throws {
        let pipeLine = try RenderPipeline(
            vertexDescriptor: .load("textureVertexShader", bundle: .module, function: vertexFunction),
            fragmentDescriptor: .load("textureFragmentShader", bundle: .module, function: fragmentFunction)
        )
        vertexFunction.items = TextureInputItem.example
        fragmentFunction.texture = try TextureContainer(.load(file: "Resources/256pallet.png", bundle: .module))
        pipelines = [pipeLine]
        try queue.addTask(.init(pipelines: pipelinesContainer))
    }
}

extension TextureInputItem {
    static var example: [TextureInputItem] {
        [
            .init(position: .init(-1, -1), uv: .init(1, 0)),
            .init(position: .init(-1, 1), uv: .init(0, 1)),
            .init(position: .init(1, -1), uv: .init(1, 0)),

            .init(position: .init(1, -1), uv: .init(1, 0)),
            .init(position: .init(-1, 1), uv: .init(0, 1)),
            .init(position: .init(1, 1), uv: .init(0, 0)),

            .init(position: .init(-0.5, -0.5), uv: .init(0, 0)),
            .init(position: .init(-0.5, 0.5), uv: .init(0, 0)),
            .init(position: .init(0.5, -0.5), uv: .init(0, 0)),

            .init(position: .init(0.5, -0.5), uv: .init(0, 0)),
            .init(position: .init(-0.5, 0.5), uv: .init(0, 0)),
            .init(position: .init(0.5, 0.5), uv: .init(0, 0))
        ]
    }
}
