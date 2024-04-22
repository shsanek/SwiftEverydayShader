import SwiftEverydayUtils

public struct ComputeTask {
    public var pipelines: ValueContainer<[ComputePipeline]>

    public init(pipelines: ValueContainer<[ComputePipeline]>) {
        self.pipelines = pipelines
    }
}
