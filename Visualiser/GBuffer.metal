//
//  GBuffer.metal
//  Visualiser
//
//  Created by Douglas Finlay on 05/06/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
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
    MaterialUniformBuffer = 2,
    ModelUniformBuffer    = 3
};

// MARK: data types
struct FrameUniforms {
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

struct ModelUniforms {
    float4x4 modelMatrix;
    float4x4 normalMatrix;
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
    float2 texCoord [[attribute(VertexAttributeTexCoord)]];
};


struct VertexOut {
    float4 position [[position]];
    float4 color;
    float4 normal;
    float4 v_model;
    float2 texCoord;
};

struct GBufferOut {
    float4 albedo   [[color(0)]];
    float4 normal   [[color(1)]];
    float4 position [[color(2)]];
};


vertex VertexOut gBufferVertex(VertexIn current [[stage_in]],
                               constant FrameUniforms *frameUniforms [[buffer(FrameUniformBuffer)]],
                               constant MaterialUniforms *materialUniforms [[buffer(MaterialUniformBuffer)]],
                               constant ModelUniforms *modelUniforms [[buffer(ModelUniformBuffer)]]) {
    VertexOut vertexOut;
    
    float4x4 viewProjection = frameUniforms->projectionMatrix * frameUniforms->viewMatrix;
    
    vertexOut.position = viewProjection * modelUniforms->modelMatrix * current.position;
    vertexOut.normal = modelUniforms->normalMatrix * current.position;
    vertexOut.texCoord = current.texCoord;
    
    return vertexOut;
}

fragment GBufferOut gBufferFragment(VertexOut inFrag [[stage_in]],
                                    texture2d<float> diffuseTexture [[texture(DiffuseTextureIndex)]]) {
    GBufferOut out;
    
    constexpr sampler diffuseSampler(min_filter::linear, mag_filter::linear);
    
    out.albedo = diffuseTexture.sample(diffuseSampler, inFrag.texCoord);
    out.normal = inFrag.normal;
    out.position = inFrag.position;
    
    return out;
}
