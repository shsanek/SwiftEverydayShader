import Metal
import Foundation
import SwiftEverydayUtils

public final class ShaderFunctionDescriptor<Function> {
    public let id: String
    public var function: Function
    public var metalFunction: MTLFunction
    
    public init(id: String, function: Function, metalFunction: MTLFunction) {
        self.id = id
        self.function = function
        self.metalFunction = metalFunction
    }
}

extension ShaderFunctionDescriptor {
    public static func load(from resource: FunctionResource, function: Function, device: MTLDevice? = nil) throws -> ShaderFunctionDescriptor {
        guard let device = device ?? MTLCreateSystemDefaultDevice() else {
            throw SwiftEverydayShaderError("Metal device not found")
        }
        let library = try device.makeDefaultLibrary(bundle: resource.bundle)
        guard let metalFunction = library.makeFunction(name: resource.name) else {
            throw SwiftEverydayShaderError("error load function with \(resource.name)")
        }
        return .init(id: resource.id, function: function, metalFunction: metalFunction)
    }

    public static func load(
        _ name: String,
        bundle: Bundle,
        function: Function,
        device: MTLDevice? = nil
    ) throws -> ShaderFunctionDescriptor {
        let resource = FunctionResource(name: name, bundle: bundle)
        guard let device = device ?? MTLCreateSystemDefaultDevice() else {
            throw SwiftEverydayShaderError("Metal device not found")
        }
        let library = try device.makeDefaultLibrary(bundle: resource.bundle)
        guard let metalFunction = library.makeFunction(name: resource.name) else {
            throw SwiftEverydayShaderError("error load function with \(resource.name)")
        }
        return .init(id: resource.id, function: function, metalFunction: metalFunction)
    }
}
