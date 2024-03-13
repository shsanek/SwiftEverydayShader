import SwiftEverydayShader
import SwiftEverydayUtils
import simd

final class Render2DExample: BaseExample, IExample {
    private let vertexFunction = Render2DVertexFunction()

    func load(size: vector_float2, queue: IRenderQueue) throws {
        let pipeLine = try RenderPipeline(
            vertexDescriptor: .load("render2DVertexShader", bundle: .module, function: vertexFunction),
            fragmentDescriptor: .load("render2DFragmentShader", bundle: .module, function: Render2DFragmentFunction())
        )
        vertexFunction.items = Render2DInputItem.example
        pipelines = [pipeLine]
        try queue.addTask(.init(pipelines: pipelinesContainer))
    }
}

extension Render2DInputItem {
    static var example: [Render2DInputItem] {
        [
            .init(position: .init(-1, -1), color: .init(1, 0, 0)),
            .init(position: .init(-1, 1), color: .init(0, 1, 0)),
            .init(position: .init(1, -1), color: .init(1, 0, 0)),

            .init(position: .init(1, -1), color: .init(1, 0, 0)),
            .init(position: .init(-1, 1), color: .init(0, 1, 0)),
            .init(position: .init(1, 1), color: .init(0, 0, 1)),

            .init(position: .init(-0.5, -0.5), color: .init(0, 0, 1)),
            .init(position: .init(-0.5, 0.5), color: .init(0, 0, 1)),
            .init(position: .init(0.5, -0.5), color: .init(0, 0, 1)),

            .init(position: .init(0.5, -0.5), color: .init(0, 0, 1)),
            .init(position: .init(-0.5, 0.5), color: .init(0, 0, 1)),
            .init(position: .init(0.5, 0.5), color: .init(0, 0, 1))
        ]
    }
}
