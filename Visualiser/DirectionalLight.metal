//
//  DirectionalLight.metal
//  Visualiser
//
//  Created by Douglas Finlay on 11/06/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    packed_float2 position;
    packed_float2 texCoord;
};

struct LightVertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct DirectionalLightFragmentShaderInput {
    float3 direction;
    float3 color;
};


vertex LightVertexOut directionalLightVertex(device VertexIn *vertices [[buffer(0)]],
                                       uint vid [[vertex_id]]) {
    LightVertexOut out;
    
    out.position = float4(vertices[vid].position, 0.0, 1.0);
    out.texCoord = vertices[vid].texCoord;
    
    return out;
}

fragment float4 directionalLightFragment(LightVertexOut in [[stage_in]],
                                   constant DirectionalLightFragmentShaderInput *lightData[[buffer(0)]],
                                   texture2d<float> normalDepthTexture [[texture(0)]]) {
    // Unpack the geometry buffer
    // Normals
    constexpr sampler textureSampler;
    float4 gBuffers = normalDepthTexture.sample(textureSampler, in.texCoord);
    float3 surfaceNormal = normalize(gBuffers.xyz); // * 2.0 - 1.0;
    
    float3 surfaceToLight = normalize(-lightData->direction);
    float diffuseCoefficient = fmax(0.0, dot(surfaceToLight, surfaceNormal));
    
    float4 diffuseColor = diffuseCoefficient * float4(lightData->color, 1.0);
    
    return diffuseColor;
}
