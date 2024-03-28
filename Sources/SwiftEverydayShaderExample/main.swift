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

//import SwiftEverydayVulkanApi
//
//let extensionNames = ["VK_KHR_surface", "VK_KHR_win32_surface"]
//
//var instanceCreateInfo: VkInstanceCreateInfo = .init(
//    sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
//    pNext: nil,
//    flags: 0,
//    pApplicationInfo: nil,
//    enabledLayerCount: 0,
//    ppEnabledLayerNames: nil,
//    enabledExtensionCount: 0,
//    ppEnabledExtensionNames: nil
//)
//
//var inst: VkInstance?
//vkCreateInstance(&instanceCreateInfo, nil, &inst);
//
//var phys: [VkPhysicalDevice?] = .init(repeating: nil, count: 4)
//var physCount: UInt32 = 4
//vkEnumeratePhysicalDevices(inst, &physCount, &phys);

App({
    MainView(renderLoop: renderLoop, metalView: metalView, examples: examples)
}).run()


