@attached(member, names: arbitrary)
public macro Shader(mutable: Bool = false) = #externalMacro(
    module: "SwiftEverydayShaderMacros",
    type: "ShaderMacro"
)

@attached(accessor, names: named(dict))
public macro Buffer(
    _ index: Int32 = 0,
    vertexIndex: Int32 = 0,
    vertexCount: Bool = false,
    fragmentIndex: Int32 = 0,
    computeIndex: Int32 = 0,
    computeCount: Bool = false, 
    sharedContainer: Bool = false
) = #externalMacro(
    module: "SwiftEverydayShaderMacros",
    type: "BufferMacro"
)

@attached(accessor, names: named(dict))
public macro IndexBuffer(sharedContainer: Bool = false) = #externalMacro(
    module: "SwiftEverydayShaderMacros",
    type: "BufferMacro"
)

@propertyWrapper
public struct VertexCount {
    public var wrappedValue: Int

    public init(wrappedValue: Int = 0) {
        self.wrappedValue = wrappedValue
    }
}


@propertyWrapper
public struct ComputeCount<ValueType> {
    public var wrappedValue: ValueType

    public init(wrappedValue: ValueType) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct TextureBuffer<Texture> {
    public var wrappedValue: Texture

    public init(wrappedValue: Texture, _ index: Int32 = 0, vertexIndex: Int32 = 0, fragmentIndex: Int32 = 0, computeIndex: Int32 = 0) {
        self.wrappedValue = wrappedValue
    }
}

extension TextureBuffer where Texture: ExpressibleByNilLiteral {
    public init(_ index: Int32 = 0, vertexIndex: Int32 = 0, fragmentIndex: Int32 = 0) {
        self.wrappedValue = nil
    }
}
