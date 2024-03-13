import SwiftEverydayApp
import SwiftEverydayShader
import simd
import SwiftEverydayUtils
import Metal
import SwiftUI

final class MainRenderLoop: IRenderQueueDelegate {
    var example: IExample? = nil {
        didSet {
            isNeedReload = true
        }
    }
    private var isNeedReload: Bool = true

    func willRender(size: vector_float2, renderQueue: IRenderQueue) throws {
        if isNeedReload {
            try example?.load(size: size, queue: renderQueue)
            isNeedReload = false
        }
        try example?.loop(size: size, queue: renderQueue)
    }
}

let examples: [IExample] = [
    Render2DExample()
]

let metalView: MetalView = try .init()
let renderLoop: MainRenderLoop = .init()
metalView.renderQueue.delegate = renderLoop

App({
    MainView(renderLoop: renderLoop, metalView: metalView, examples: examples)
}).run()
