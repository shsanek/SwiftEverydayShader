import Metal

public struct Device {
    let mtlDevice: MTLDevice

    public static var defaultDevice: Device? = MTLCreateSystemDefaultDevice().flatMap({ .init(mtlDevice: $0) })
}
