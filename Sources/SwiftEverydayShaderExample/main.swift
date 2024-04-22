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
    private var size: vector_int2 = .zero

    func willRender(size: vector_float2, renderQueue: IRenderQueue) throws {
        let int_size = vector_int2(Int32(size.x), Int32(size.y))
        if isNeedReload {
            try example?.load(size: size, queue: renderQueue)
            isNeedReload = false
            try example?.updateSize(size: int_size, queue: renderQueue)
            try example?.updateSize(size: size, queue: renderQueue)
            self.size = int_size
        } else {
            if int_size != self.size {
                try example?.updateSize(size: int_size, queue: renderQueue)
                try example?.updateSize(size: size, queue: renderQueue)
                self.size = int_size
            }
        }
        try example?.loop(size: size, queue: renderQueue)
    }
}

let examples: [IExample] = [
    Render2DExample(),
    Render3DExample(),
    TextureExample(),
    LifeExample(),
]

let metalView: MetalView = try .init()
let renderLoop: MainRenderLoop = .init()
metalView.renderQueue.delegate = renderLoop

App({
    MainView(renderLoop: renderLoop, metalView: metalView, examples: examples)
}).run()
