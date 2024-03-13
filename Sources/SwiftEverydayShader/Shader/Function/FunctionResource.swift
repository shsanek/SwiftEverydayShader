import Foundation

public final class FunctionResource {
    public let name: String
    public let bundle: Bundle

    public var id: String {
        "\(bundle):\(name)"
    }

    public init(name: String, bundle: Bundle) {
        self.name = name
        self.bundle = bundle
    }
}
