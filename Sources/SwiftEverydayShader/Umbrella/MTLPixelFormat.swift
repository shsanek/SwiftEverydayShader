import Metal

public enum PixelFormat: UInt {
    case rgba = 81

    var mtlPixelFormat: MTLPixelFormat {
        MTLPixelFormat(rawValue: self.rawValue)!
    }
}
