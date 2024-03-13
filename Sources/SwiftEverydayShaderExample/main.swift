import SwiftEverydayApp
import SwiftEverydayShader
import simd
import SwiftEverydayUtils
import Metal
import SwiftUI

final class MainRenderLoop: IViewRenderLoop {
    var example: IExample? = nil

    func render(size: vector_float2, render: (ValueContainer<[IRenderPipeline]>) throws -> Void) throws {
        try example?.render(size: size, render: render)
    }
}

let examples: [IExample] = [
    Render2DExample()
]

App({
    MainView(examples: examples)
}).run()
