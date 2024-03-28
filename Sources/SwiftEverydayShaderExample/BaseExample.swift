import SwiftEverydayUtils
import SwiftEverydayShader
import simd

class BaseExample {
    @ValueContainer var pipelines: [IRenderPipeline] = []
    var pipelinesContainer: ValueContainer<[IRenderPipeline]> {
        _pipelines
    }
    let name: String

    init(name: String? = nil) {
        self.name = name ?? "\(Self.self)"
    }
}

protocol IExample {
    var name: String { get }
    func loop(size: vector_float2, queue: IRenderQueue) throws
    func load(size: vector_float2, queue: IRenderQueue) throws
}

extension IExample {
    func loop(size: vector_float2, queue: IRenderQueue) throws { }
    func load(size: vector_float2, queue: IRenderQueue) throws { }
}
