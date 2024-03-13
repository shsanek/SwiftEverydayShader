public protocol IRenderQueue {
    func addTask(_ task: RenderTask) throws
}
