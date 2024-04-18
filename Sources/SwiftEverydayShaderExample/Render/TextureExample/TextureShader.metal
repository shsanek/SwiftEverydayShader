#include <metal_stdlib>

using namespace metal;

struct VertexTextureInputItem {
    float2 position;
    float2 uv;
};

struct FragmentTextureInputItem {
    float4 position [[position]];
    float2 uv;
};

vertex FragmentTextureInputItem textureVertexShader(
    uint itemID [[ vertex_id ]],
    constant VertexTextureInputItem *input [[ buffer(0) ]]
) {
    VertexTextureInputItem current = input[itemID];
    FragmentTextureInputItem out;
    out.position = float4(current.position.x, current.position.y, 0, 1);
    out.uv = current.uv;
    return out;
}

fragment float4 textureFragmentShader(
    FragmentTextureInputItem in [[stage_in]],
    texture2d<float> texture [[texture(0)]]
) {
    constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);

    float4 color = texture.sample(colorSampler, in.uv);

    return color;
}
