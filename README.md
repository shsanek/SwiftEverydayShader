# SwiftEverydayShader

A handy wrapper over MetalApi. A handy wrapper over MetalApi. Currently only supports RenderPipeline. You can always check out the SwiftEverydayShaderExample in Mac.

## RenderPipeline Example

Example shader:

``` metal
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
) {...}

fragment float4 render2DFragmentShader(
    Fragment2DInputItem in [[stage_in]],
    constant int *input [[ buffer(1) ]]
) {...}
```

In order to use such a shader in swift you need

0. Import 
```
import SwiftEverydayShader
import SwiftEverydayUtils
```
`For vectors you need import simd`

1. Create model
```
struct Render2DInputItem: RawEncodable {
    let position: vector_float2
    let color: vector_float3
}
```
`RawEncodable protocol that decomposes an object into a Metal representation, for simple structures does not require implementation`

2. Write two wrappers for buffer transfer
``` swift
@Shader
final class Render2DVertexFunction: IVertexFunction {
    @Buffer(0, vertexCount: true) var items: [Render2DInputItem] = []
}

@Shader
final class Render2DFragmentFunction: IFragmentFunction {
    @Buffer(1) var items: [Int32] = []
}
```
`Note that index must correspond to index in Metal and VertexFunction must contain the field Buffer with vertexCount == true or IndexBuffer or VertexCount.`

3. Create a pipeline with your functions
```
let vertexFunction = Render2DVertexFunction()
let fragmentFunction = Render2DFragmentFunction()
let pipeline = try RenderPipeline(
    vertexDescriptor: .load("render2DVertexShader", bundle: .module, function: vertexFunction),
    fragmentDescriptor: .load("render2DFragmentShader", bundle: .module, function: fragmentFunction)
)
```

4. Create a pipeline with your functions
```
vertexFunction.items = ...
fragmentFunction.items = ...
```

5. Сreate a contenter for the array with pipelines and add your own 
```
@ValueContainer var pipelines: [IRenderPipeline] = []
pipelines = [pipeline]
```

6. Create a MetalView in the desired location and send your contenter for rendering
```
let metalView: MetalView = try .init()
metalView.addTask(.init(pipelines: _pipelines))
```

Done!

## Shader accessor macros


At the moment there are several types of buffers that you can use in your shader. Buffer macros can only be used in `@Shader` objects. For each buffer a private variable `_propertyNameBufferContainer: BufferContainer<T>` will be created. If you want to reuse the same buffer you can use `sharedContainer: true` then `_propertyNameBufferContainer` will be created as public 

#### Buffer
`@Buffer(_ index: Int32 = 0,
    vertexIndex: Int32 = 0,
    vertexCount: Bool = false,
    fragmentIndex: Int32 = 0,
    computeIndex: Int32 = 0,
    computeCount: Bool = false, 
    sharedContainer: Bool = false
) var name: [Value]` - The standard buffer can be used in all kinds of shaders. Create a variable in the shader `private var _\(name)BufferContainer: BufferContainer<Type>`

`index` - common index will be used for all shaders if no specialized index is set

`vertexIndex`, `fragmentIndex`, `computeIndex` - specialized indexes will be used to communicate with a specific shader

`sharedContainer` - if true will change the access to the buffer to the same access as that of the class

`vertexCount`, `computeCount` - is used to calculate dimensions. if an array is specified, its count will be used. But the real size can be specified for vertex (UInt32, Int32), and for compute UInt32, Int32, vector_int2, vector_int3, vector_uint3, vector_uint2. Will work similarly to VertexCount, ComputeCount - but will also create a buffer

#### IndexBuffer
`@IndexBuffer(sharedContainer:) var name: [UInt32]` - The index buffer will be used in the vertex shader when `drawIndexedPrimitives` is called. available types [UInt32] or [UInt16]

#### VertexCount
`@VertexCount var count: Int` - Is not a buffer. it will be used when `drawPrimitives` method is called. conflicts with `Buffer(vertexCount: true)` and `IndexBuffer`. Supports only `Int`. If you want to use this value as a buffer and pass it to the shader, use @Buffer(vertexCount: true)

#### СomputeCount
`@VertexCount var count: Int` - Is not a buffer. It will be used to calculate GridSize and call dispatchThreads`. Supports only UInt32, Int32, vector_int2, vector_int3, vector_uint3, vector_uint2. If you want to use this value as a buffer and pass it to the shader, use @Buffer(computeCount: true)

#### Texture
`@Texture(_ index:vertexIndex:fragmentIndex:computeIndex:) var texture: ITexture` - adds a texture object in the shader

## Function

### IFragmentFunction

When using `@Shader` and declaring `IFragmentFunction` protocol support, a `_prepareFragment` method that sets all buffers in fragment shader. To customise the behaviour you can reload  `prepareFragment` while the methods with `_` will not be called, but you can call them manually.

### IVertexFunction

When using `@Shader` and declaring `IVertexFunction` protocol support, a `_readyForRendering: Bool` (true when there is something to draw) variable will be created, and a `_render`, `_prepareVertex` method that sets all buffers in vertex shader and calls one of the drawing methods. To customise the behaviour you can reload `readyForRendering` and `render`(don't forget to call `prepareVertex`), `prepareVertex` while the methods with `_` will not be called, but you can call them manually.

### IComputeFunction

When using `@Shader` and declaring `IComputeFunction` protocol support, a `_prepareCompute`, `_runCompute` methods that sets all buffers in vertex shader and calls one of the run methods. To customise the behaviour you can reload `runCompute`(don't forget to call `prepareCompute`), `prepareCompute` while the methods with `_` will not be called, but you can call them manually.


The `@Shader` must contain one of the following combinations:

##### Only `Buffer(vertexCount: true)`
```
@Shader
struct MyFunction: IVertexFunction {
@Buffer(0, vertexCount: true) var vertex = [...]
...
}
```
When rendering, the method `drawPrimitives` method will be called and the length of `vertex` array will be passed to the `vertexCount` parameter  

##### `IndexBuffer` not null
```
@Shader
struct MyFunction: IVertexFunction {
@Buffer(0, vertexCount: true) var vertex: ...
@IndexBuffer var index: [UInt32]
...
}
```
or
```
@Shader
struct MyFunction: IVertexFunction {
@IndexBuffer var index: [UInt32]
...
}
```
in both cases the drawIndexedPrimitives method will be called where the index buffer will be passed in

##### `IndexBuffer` optional and `Buffer(vertexCount: true)`
```
@Shader
struct MyFunction: IVertexFunction {
@Buffer(0, vertexCount: true) var vertex: ...
@IndexBuffer var index: [UInt32]?
...
}
```
if index is nil then Only `VertexBuffer` will be used otherwise `IndexBuffer` not null


##### `VertexCount`
```
@Shader
struct MyFunction: IVertexFunction {
@VertexCount var count: Int
...
}
```

When rendering, the `drawPrimitives` method will be called and `count` will be passed to the `vertexCount` parameter
