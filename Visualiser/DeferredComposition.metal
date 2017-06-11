//
//  DeferredComposition.metal
//  Visualiser
//
//  Created by Douglas Finlay on 08/06/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    packed_float2 position;
    packed_float2 texCoord;
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};


vertex VertexOut compositionVertex(const device VertexIn* vertexArray [[buffer(0)]],
                              unsigned int vid [[vertex_id]]) {
    VertexOut out;

    out.position = float4(vertexArray[vid].position, 0.0, 1.0);
    out.texCoord = vertexArray[vid].texCoord;
    
    return out;
}

fragment float4 compositionFragment(VertexOut in [[stage_in]],
                                    texture2d<float> albedo [[texture(0)]],
                                    texture2d<float> normals [[texture(1)]]) {
    constexpr sampler albedoSampler(min_filter::linear, mag_filter::linear);
    constexpr sampler normalsSampler(min_filter::linear, mag_filter::linear);
    
    float4 outColor = albedo.sample(albedoSampler, in.texCoord);
    
    return outColor;
}
