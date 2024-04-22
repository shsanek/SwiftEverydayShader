#include <metal_stdlib>

using namespace metal;

struct Vertex3DInputItem {
    float3 position;
    float3 color;
};

struct Fragment3DInputItem {
    float4 position [[position]];
    float3 color;
};

vertex Fragment3DInputItem render3DVertexShader(
    uint itemID [[ vertex_id ]],
    constant Vertex3DInputItem *input [[ buffer(0) ]],
    constant float4x4 *projection [[ buffer(1) ]],
    constant float4x4 *cameraTransform [[ buffer(2) ]],
    constant float4x4 *objectTransform [[ buffer(3) ]]

) {
    Vertex3DInputItem current = input[itemID];
    Fragment3DInputItem out;
    float4 localPosition = float4(current.position, 1);
    out.color = current.color;
    out.position = (*projection) * ((*cameraTransform) * ((*objectTransform) * localPosition));
    return out;
}

fragment float4 render3DFragmentShader(
    Fragment3DInputItem in [[stage_in]]
) {
    return float4(in.color, 1);
}
