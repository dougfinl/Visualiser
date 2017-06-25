//
//  RenderableLight.swift
//  Visualiser
//
//  Created by Douglas Finlay on 12/06/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import MetalKit
import simd

struct DirectionalLightFragmentShaderInput {
    var direction: float3
    var color: float3
}

class RenderableDirectionalLight {
    
    private var areaOfInfluenceVertexBuffer: MTLBuffer
    
    var directionalLight: DirectionalLight
    
    var fragmentShaderInputBuffer: MTLBuffer
    
    var fragmentShaderInput: DirectionalLightFragmentShaderInput
    
    init(directionalLight: DirectionalLight, device: MTLDevice) {
        self.directionalLight          = directionalLight
        self.fragmentShaderInputBuffer = device.makeBuffer(length: MemoryLayout<DirectionalLightFragmentShaderInput>.size, options: [])
        self.fragmentShaderInput       = DirectionalLightFragmentShaderInput(direction: directionalLight.direction, color: directionalLight.color)
        
        // Full-screen 2D quad
        var quadVerts = Array(repeating: Vertex(), count: 6)
        quadVerts[0].position = (-1,1)  // top left
        quadVerts[0].texCoord = (0,0)
        quadVerts[1].position = (1,1)   // top right
        quadVerts[1].texCoord = (1,0)
        quadVerts[2].position = (1,-1)  // bottom right
        quadVerts[2].texCoord = (1,1)
        quadVerts[3] = quadVerts[0]
        quadVerts[4] = quadVerts[2]
        quadVerts[5].position = (-1,-1) // bottom left
        quadVerts[5].texCoord = (0,1)
        self.areaOfInfluenceVertexBuffer = device.makeBuffer(bytes: quadVerts, length: MemoryLayout<Float>.size * 24, options:[])
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        let pFragmentShaderInputBuffer = self.fragmentShaderInputBuffer.contents()
        memcpy(pFragmentShaderInputBuffer, &self.fragmentShaderInput, MemoryLayout<DirectionalLightFragmentShaderInput>.size)
    
        encoder.setVertexBuffer(areaOfInfluenceVertexBuffer, offset: 0, at: 0)
        encoder.setFragmentBuffer(fragmentShaderInputBuffer, offset: 0, at: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
    
    func update(camera: Camera) {
        if directionalLight.isDirty {
            fragmentShaderInput.direction = directionalLight.direction
            fragmentShaderInput.color     = directionalLight.color
        }
    }
    
}
