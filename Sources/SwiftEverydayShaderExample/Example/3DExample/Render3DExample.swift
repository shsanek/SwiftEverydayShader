import SwiftEverydayShader
import SwiftEverydayUtils
import simd

final class Render3DExample: BaseExample, IExample {
    private let vertexFunction = Render3DVertexFunction()
    private var rotate: Float32 = 0.0

    func load(size: vector_float2, queue: IRenderQueue) throws {
        let pipeLine = try RenderPipeline(
            vertexDescriptor: .load("render3DVertexShader", bundle: .module, function: vertexFunction),
            fragmentDescriptor: .load("render3DFragmentShader", bundle: .module, function: Render3DFragmentFunction())
        )
        vertexFunction.items = Render3DInputItem.example + Render3DInputItem.example.reversed()
        pipelines = [pipeLine]
        vertexFunction.cameraTransform = .translationMatrix4x4(0, 0, -5)
    }

    func updateSize(size: vector_float2, queue: IRenderQueue) throws {
        let aspect = size.x / size.y
        vertexFunction.projection = .perspectiveMatrix(aspectRatio: aspect)
    }

    func loop(size: vector_float2, queue: IRenderQueue) throws {
        rotate += .pi * 0.01
        vertexFunction.objectTransform = .rotationMatrix4x4(radians: rotate, axis: .init(x: 0, y: 1, z: 0))
        try queue.addTask(.init(pipelines: pipelinesContainer))
    }

}

extension Render3DInputItem {
    static var example: [Render3DInputItem] {
        [
            .init(position: .init(-1, -1, -1), color: .init(1, 0, 0)),
            .init(position: .init(0, 1, 0.0), color: .init(1, 0, 0)),
            .init(position: .init(1, -1, -1), color: .init(1, 0, 0)),

            .init(position: .init(0, -1, 1), color: .init(0, 1, 0)),
            .init(position: .init(0, 1, 0.0), color: .init(0, 1, 0)),
            .init(position: .init(1, -1, -1), color: .init(0, 1, 0)),
        ]
    }
}

