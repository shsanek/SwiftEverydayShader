import SwiftEverydayUtils
import SwiftEverydayShader
import simd

class BaseExample {
    @ValueContainer var pipelines: [IRenderPipeline] = []
    fileprivate var isLoaded: Bool = false
    fileprivate var pipelinesContainer: ValueContainer<[IRenderPipeline]> {
        get {
            _pipelines
        }
    }
    let name: String

    init(name: String? = nil) {
        self.name = name ?? "\(Self.self)"
    }

    func loop(size: vector_float2) throws {}
}

protocol IExample {
    var name: String { get }
    func loop(size: vector_float2) throws
    func load(size: vector_float2) throws
    func render(size: vector_float2, render: (ValueContainer<[IRenderPipeline]>) throws -> Void) throws
}

extension IExample {
    func loop(size: vector_float2) { }
}

extension IExample where Self: BaseExample {
    private func loadIfNeeded(size: vector_float2) throws {
        guard !isLoaded else {
            return
        }
        defer {
            isLoaded = true
        }
        try load(size: size)
    }

    func render(size: vector_float2, render: (ValueContainer<[IRenderPipeline]>) throws -> Void) throws {
        try loadIfNeeded(size: size)
        try loop(size: size)
        try render(pipelinesContainer)
    }
}
