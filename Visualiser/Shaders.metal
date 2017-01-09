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

struct VertexIn {
    float4 position [[attribute(0)]];
    float4 normal [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 normal;
    float4 color;
};

vertex VertexOut simpleSceneVertex(VertexIn current [[stage_in]],
                                   constant Uniforms *uniforms [[buffer(2)]]) {
    VertexOut vertexOut;
    
    float4x4 viewProjection = uniforms->projectionMatrix * uniforms->viewMatrix;
    
    vertexOut.position = viewProjection * current.position;
    vertexOut.normal = viewProjection * current.normal;
    vertexOut.color = float4(1.0f, 1.0f, 1.0f, 1.0f);
    
    return vertexOut;
}

fragment half4 simpleSceneFragment(VertexOut inFrag [[stage_in]]) {
    return half4(inFrag.color);
}
