#include <metal_stdlib>

using namespace metal;

struct VertexLifeInputItem {
    float2 position;
    float2 uv;
};

struct FragmentLifeInputItem {
    float4 position [[position]];
    float2 uv;
};

kernel void lifeComputeShader(
  device uchar* newItems [[ buffer(0) ]],
  constant uchar* oldItems [[ buffer(1) ]],
  constant int2* sizeIn [[ buffer(2) ]],
  uint2 index [[thread_position_in_grid]]
)
{
    int2 size = sizeIn[0];
    int count = 0;
    for (int x = -1; x < 2; x++) {
        for(int y = -1; y < 2; y++) {
            if (!(x == 0 && y == 0)) {
                count += oldItems[(index.x + x + size.x) % size.x + size.x * ((index.y + y + size.y) % size.y)];
            }
        }
    }

    newItems[(index.x) + size.x * ((index.y))] = count;

    if (oldItems[(index.x) + size.x * ((index.y))] > 0) {
        if (!(count == 2 || count == 3)) {
            newItems[(index.x) + size.x * ((index.y))] = 0;
        } else {
            newItems[(index.x) + size.x * ((index.y))] = 1;
        }
    } else {
        if (count == 3) {
            newItems[(index.x) + size.x * ((index.y))] = 1;
        } else {
            newItems[(index.x) + size.x * ((index.y))] = 0;
        }
    }
}

vertex FragmentLifeInputItem lifeVertexShader(
    uint itemID [[ vertex_id ]],
    constant VertexLifeInputItem *input [[ buffer(0) ]]
) {
    VertexLifeInputItem current = input[itemID];
    FragmentLifeInputItem out;
    out.position = float4(current.position.x, current.position.y, 0, 1);
    out.uv = current.uv;
    return out;
}

fragment float4 lifeFragmentShader(
    FragmentLifeInputItem in [[stage_in]],
    constant uchar *input [[ buffer(0) ]],
    constant int2* size [[ buffer(1) ]]
) {
    int x = in.uv.x * size[0].x;
    int y = in.uv.y * size[0].y;
    if (x >= size[0].x) {
        x = size[0].x - 1;
    }
    if (y >= size[0].y) {
        y = size[0].y - 1;
    }
    int point = size[0].x * y + x;
    return float4(input[point], input[point], input[point], 1);
}

