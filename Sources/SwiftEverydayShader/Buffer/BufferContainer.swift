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

    public func getGPUData(device: MTLDevice) throws -> [Element] {
        if count == 0 {
            return []
        }
        guard let buffer = try self.getBuffer(for: device) else {
            return []
        }
        let out = buffer.contents().bindMemory(to: Element.self, capacity: count)
        var result: [Element] = []
        result.reserveCapacity(count)
        for i in 0..<count {
            result.append(out[i])
        }
        out.deallocate()
        return result
    }
}

