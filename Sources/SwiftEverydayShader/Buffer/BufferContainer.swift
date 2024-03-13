import Metal

public final class BufferContainer<Element: RawEncodable> {
    public var values: [Element] {
        didSet {
            buffer.setNeedUpdate()
        }
    }

    public var count: Int {
        values.count
    }

    private let buffer = MetalBufferCache()

    public init(_ values: [Element] = []) {
        self.values = values
    }

    public func getBuffer(for device: MTLDevice) throws -> MTLBuffer? {
        try buffer.getBuffer(values, device: device)
    }
}
