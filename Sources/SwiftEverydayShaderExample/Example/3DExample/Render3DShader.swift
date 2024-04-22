import SwiftEverydayShader
import simd
import Metal

struct Render3DInputItem: RawEncodable {
    let position: vector_float3
    let color: vector_float3
}


@Shader
final class Render3DVertexFunction: IVertexFunction {
    @Buffer(0, vertexCount: true) var items: [Render3DInputItem] = []
    @Buffer(1) var projection: matrix_float4x4 = .init(1)
    @Buffer(2) var cameraTransform: matrix_float4x4 = .init(1)
    @Buffer(3) var objectTransform: matrix_float4x4 = .init(1)
}

@Shader
final class Render3DFragmentFunction: IFragmentFunction {
}
