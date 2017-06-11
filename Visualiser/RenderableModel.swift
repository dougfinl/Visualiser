//
//  RenderableModel.swift
//  Visualiser
//
//  Created by Douglas Finlay on 06/03/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Metal
import simd

class RenderableModel: NSObject {
    
    var model: Model
    
    var mesh: Mesh
    
    var modelUniforms = ModelUniforms()
    
    var modelUniformBuffer: MTLBuffer
    
    var modelMatrix: float4x4 = identity()
    var normalMatrix: float4x4 = identity()
    
    init(model: Model, mesh: Mesh, device: MTLDevice) {
        self.model = model
        self.mesh = mesh
        self.modelUniformBuffer = device.makeBuffer(length: MemoryLayout<ModelUniforms>.size, options: [])
        
        super.init()
    }

    func render(encoder: MTLRenderCommandEncoder) {
        self.modelUniforms.modelMatrix = self.modelMatrix
        self.modelUniforms.normalMatrix = self.normalMatrix
        
        let pModelUniformBuffer = self.modelUniformBuffer.contents()
        memcpy(pModelUniformBuffer, &self.modelUniforms, MemoryLayout<ModelUniforms>.size)

        encoder.setVertexBuffer(self.modelUniformBuffer, offset: 0, at: BufferIndex.ModelUniformBuffer.rawValue)
        
        self.mesh.render(encoder: encoder)
    }
    
    func update(camera: Camera) {
        if model.isDirty {
            NSLog("recomputing")
            
            self.modelMatrix = translate(x: model.positionX, y: model.positionY, z: model.positionZ) * rotate(x: radians(fromDegrees: model.rotationX), y: radians(fromDegrees: model.rotationY), z: radians(fromDegrees: model.rotationZ)) * scale(x: model.mscale, y: model.mscale, z: model.mscale)
            
            let modelViewMatrix = camera.viewMatrix * self.modelMatrix
            self.normalMatrix = modelViewMatrix.inverse.transpose
        }
    }
    
}
