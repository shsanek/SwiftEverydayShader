#include <metal_stdlib>

using namespace metal;

struct Vertex2DInputItem {
    float2 position;
    float3 color;
};

struct Fragment2DInputItem {
    float4 position [[position]];
    float3 color;
};

vertex Fragment2DInputItem render2DVertexShader(
    uint itemID [[ vertex_id ]],
    constant Vertex2DInputItem *input [[ buffer(0) ]]
) {
    Vertex2DInputItem current = input[itemID];
    Fragment2DInputItem out;
    out.color = current.color;
    out.position = float4(current.position.x, current.position.y, 0, 1);
    return out;
}

fragment float4 render2DFragmentShader(
    Fragment2DInputItem in [[stage_in]]
) {
    return float4(in.color, 1);
}
