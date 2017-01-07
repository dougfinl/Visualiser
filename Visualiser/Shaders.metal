//
//  Shaders.metal
//  Visualiser
//
//  Created by Douglas Finlay on 30/12/2016.
//  Copyright © 2016 Douglas Finlay. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct Uniforms {
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

struct VertexInOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexInOut simpleSceneVertex(uint vid [[vertex_id]],
                                     constant packed_float4 *position [[buffer(0)]],
                                     constant packed_float4 *color [[buffer(1)]],
                                     constant Uniforms *uniforms [[buffer(2)]]) {
    VertexInOut outVertex;
    
    outVertex.position = uniforms->projectionMatrix * uniforms->viewMatrix * float4(position[vid]);
    outVertex.color = color[vid];
    
    return outVertex;
}

fragment half4 simpleSceneFragment(VertexInOut inFrag [[stage_in]]) {
    return half4(inFrag.color);
}
