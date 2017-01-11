//
//  Shaders.metal
//  Visualiser
//
//  Created by Douglas Finlay on 30/12/2016.
//  Copyright © 2016 Douglas Finlay. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


// MARK: binding points
enum VertexAttributes {
    VertexAttributePosition = 0,
    VertexAttributeNormal   = 1,
    VertexAttributeTexCoord = 2
};

enum TextureIndex {
    DiffuseTextureIndex = 0
};

enum BufferIndex {
    MeshVertexBuffer      = 0,
    FrameUniformBuffer    = 1,
    MaterialUniformBuffer = 2
};
    

// MARK: data types
struct FrameUniforms {
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

struct MaterialUniforms {
    float4 emissiveColor;
    float4 diffuseColor;
    float4 specularColor;
    
    float specularIntensity;
    float pad1;
    float pad2;
    float pad3;
};

struct VertexIn {
    float4 position [[attribute(VertexAttributePosition)]];
    float4 normal   [[attribute(VertexAttributeNormal)]];
    half2  texCoord [[attribute(VertexAttributeTexCoord)]];
};

struct VertexOut {
    float4 position [[position]];
    half2  texCoord;
    half4  color;
};

constexpr sampler s(coord::normalized,
                    address::repeat,
                    filter::linear);

vertex VertexOut simpleSceneVertex(VertexIn current [[stage_in]],
                                   constant FrameUniforms *frameUniforms [[buffer(FrameUniformBuffer)]],
                                   constant MaterialUniforms *materialUniforms [[buffer(MaterialUniformBuffer)]]) {
    VertexOut vertexOut;
    
    float4x4 viewProjection = frameUniforms->projectionMatrix * frameUniforms->viewMatrix;
    
    vertexOut.position = viewProjection * current.position;
//    vertexOut.color = half4(1.0f, 1.0f, 1.0f, 1.0f);
    vertexOut.texCoord = current.texCoord;
    
    return vertexOut;
}

fragment half4 simpleSceneFragment(VertexOut inFrag [[stage_in]],
                                   texture2d<half> diffuseTexture [[texture(DiffuseTextureIndex)]]) {
    constexpr sampler defaultSampler;
    
    half4 color = diffuseTexture.sample(defaultSampler, float2(inFrag.texCoord));
    
    return half4(color);
}
