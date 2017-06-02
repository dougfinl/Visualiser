//
//  SubMesh.swift
//  Visualiser
//
//  Created by Douglas Finlay on 08/01/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import MetalKit

class Submesh {
    
    private var submesh: MTKSubmesh
    
    private var materialUniforms: MTLBuffer
    
    private var diffuseTexture: MTLTexture! = nil
    
    init(mtkSubmesh: MTKSubmesh, mdlSubmesh: MDLSubmesh, device: MTLDevice) {
        submesh = mtkSubmesh
        
        materialUniforms = device.makeBuffer(length: MemoryLayout<MaterialUniforms>.size, options: [])
        var tmpMaterialUniforms = MaterialUniforms()
        
        if let property = mdlSubmesh.material?.property(with: .baseColor) {
            if property.type == .string {
                let diffuseTextureURL = URL(fileURLWithPath: property.stringValue!)
                
                let textureLoader = MTKTextureLoader(device: device)
                do {
                    try self.diffuseTexture = textureLoader.newTexture(withContentsOf: diffuseTextureURL, options: [:])
                    NSLog("loaded diffuse texture \(diffuseTextureURL.absoluteString)")
                } catch let error {
                    NSLog("failed to load diffuse texture from \(diffuseTextureURL.absoluteString): \(error)")
                }
            } else if property.type == .float4 {
                tmpMaterialUniforms.diffuseColor = property.float4Value
            } else if property.type == .float3 {
                tmpMaterialUniforms.diffuseColor.x = property.float3Value.x
                tmpMaterialUniforms.diffuseColor.y = property.float3Value.y
                tmpMaterialUniforms.diffuseColor.z = property.float3Value.z
                tmpMaterialUniforms.diffuseColor.w = 1.0
            } else if property.type == .color {
                tmpMaterialUniforms.diffuseColor.x = Float(property.color!.components![0])
                tmpMaterialUniforms.diffuseColor.y = Float(property.color!.components![1])
                tmpMaterialUniforms.diffuseColor.z = Float(property.color!.components![2])
                tmpMaterialUniforms.diffuseColor.w = Float(property.color!.components![3])
            } else {
                NSLog("warning]: found base color of unhandled type \(property.type.rawValue)")
            }
            
            // If the mesh has no texture, assign the default white texture
            if self.diffuseTexture == nil {
                do {
                    let textureLoader = MTKTextureLoader(device: device)
                    try self.diffuseTexture = textureLoader.newTexture(withName: "white_pixel", scaleFactor: 1, bundle: nil, options: [:])
                } catch let error {
                    NSLog("failed to load default diffuse texture: \(error)")
                }
            }
        }
        
//        NSLog("material uniforms: \(tmpMaterialUniforms)")
        
        let pMaterialUniforms = materialUniforms.contents()
        memcpy(pMaterialUniforms, &tmpMaterialUniforms, MemoryLayout<MaterialUniforms>.size);
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        if diffuseTexture != nil {
            encoder.setFragmentTexture(diffuseTexture, at: TextureIndex.DiffuseTextureIndex.rawValue)
        }
        
        encoder.setVertexBuffer(materialUniforms, offset: 0, at: BufferIndex.MaterialUniformBuffer.rawValue)
        encoder.setFragmentBuffer(materialUniforms, offset: 0, at: BufferIndex.MaterialUniformBuffer.rawValue)
        
        encoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
    }
    
}
