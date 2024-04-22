import SwiftEverydayShader
import simd
import Metal

@Shader
final class Render2DVertexFunction: IVertexFunction {
    @Buffer(0, vertexCount: true) var items: [Render2DInputItem]
}

@Shader
final class Render2DFragmentFunction: IFragmentFunction {
}

struct Render2DInputItem: RawEncodable {
    let position: vector_float2
    let color: vector_float3

    init(position: vector_float2, color: vector_float3) {
        self.position = position
        self.color = color
    }
}
