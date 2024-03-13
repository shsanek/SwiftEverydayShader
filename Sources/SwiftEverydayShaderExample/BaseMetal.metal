#include <metal_stdlib>

using namespace metal;

struct VertexInputItem {
    float2 position;
    float3 color;
};

struct FragmentInputItem {
    float4 position [[position]];
    float3 color;
};

vertex FragmentInputItem spriteVertexShader(
    uint itemID [[ vertex_id ]],
    constant VertexInputItem *input [[ buffer(0) ]]
) {
    VertexInputItem current = input[itemID];
    FragmentInputItem out;
    out.color = current.color;
    out.position = float4(current.position.x, current.position.y, 0, 1);
    return out;
}

fragment float4 spriteFragmentShader(
    FragmentInputItem in [[stage_in]]
) {
    return float4(in.color, 1);
}
