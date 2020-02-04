//
//  Shaders.metal
//  hello-triangle
//
//  Created by CrazyDecode on 2020/2/4.
//  Copyright © 2020 CrazyDecode. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
};


vertex Vertex CDVertexShader(constant Vertex *vertexArray [[ buffer(0) ]],
             uint vid [[vertex_id]
                       ]) {
    Vertex out;
    out.position = vertexArray[vid].position;
    return out;
}



fragment float4 CDFragmentShader(Vertex in [[stage_in]]) {
    return float4(0.3,0.1,0.2,1.0); //可以自由调整颜色
}
