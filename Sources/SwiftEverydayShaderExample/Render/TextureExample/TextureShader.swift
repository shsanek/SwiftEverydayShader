import SwiftEverydayShader
import simd
import Metal

@Shader
final class TextureVertexFunction: IVertexFunction {
    @Buffer(0, vertexCount: true) var items: [TextureInputItem]
}

@Shader
final class TextureFragmentFunction: IFragmentFunction {
    @TextureBuffer(0) var texture: ITexture?
}

struct TextureInputItem: RawEncodable {
    let position: vector_float2
    let uv: vector_float2

    init(position: vector_float2, uv: vector_float2) {
        self.position = position
        self.uv = uv
    }
}
