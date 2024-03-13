import SwiftEverydayUtils

public struct RenderTask {
    public var pipelines: ValueContainer<[IRenderPipeline]>

    public init(pipelines: ValueContainer<[IRenderPipeline]>) {
        self.pipelines = pipelines
    }
}
