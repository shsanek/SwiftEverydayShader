import SwiftEverydayShader
import SwiftEverydayUtils
import simd

final class LifeExample: BaseExample, IExample {
    private let vertexFunction = LifeVertexFunction()
    private let fragmentFunction = LifeFragmentFunction()
    private let computeFunction = LifeComputeFunction()

    private var computePipeline: ComputePipeline?
    private var renderPipeline: IRenderPipeline?

    func load(size: vector_float2, queue: IRenderQueue) throws {
        renderPipeline = try RenderPipeline(
            vertexDescriptor: .load("lifeVertexShader", bundle: .module, function: vertexFunction),
            fragmentDescriptor: .load("lifeFragmentShader", bundle: .module, function: fragmentFunction)
        )
        vertexFunction.items = LifeExample.example
        fragmentFunction._sizeBufferContainer = computeFunction._sizeBufferContainer
        computePipeline = try .init(computeDescriptor: .load("lifeComputeShader", bundle: .module, function: computeFunction))
    }

    func loop(size: vector_float2, queue: IRenderQueue) throws {
        if Int32(size.x / 2) != computeFunction.size.x || Int32(size.y / 2) != computeFunction.size.y {
            computeFunction.update(.init(Int32(size.x / 2), Int32(size.y / 2)))
        }
        if let computePipeline {
            try ComputeExecutor.global?.run(computePipeline)
        }

        if let renderPipeline {
            fragmentFunction._itemsBufferContainer = computeFunction._newBufferContainer
            pipelines = [renderPipeline]
            try queue.addTask(.init(pipelines: pipelinesContainer))
        }
    }
}

extension LifeExample {
    static var example: [TextureInputItem] {
        [
            .init(position: .init(-1, -1), uv: .init(1, 1)),
            .init(position: .init(-1, 1), uv: .init(0, 1)),
            .init(position: .init(1, -1), uv: .init(1, 0)),

            .init(position: .init(1, -1), uv: .init(1, 0)),
            .init(position: .init(-1, 1), uv: .init(0, 1)),
            .init(position: .init(1, 1), uv: .init(0, 0)),
        ]
    }
}
