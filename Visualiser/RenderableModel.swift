//
//  RenderableModel.swift
//  Visualiser
//
//  Created by Douglas Finlay on 06/03/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Metal

class RenderableModel: NSObject {
    
    dynamic var model: Model
    
    var mesh: Mesh
    
    var modelUniforms = ModelUniforms()
    
    var modelUniformBuffer: MTLBuffer
    
    init(model: Model, mesh: Mesh, device: MTLDevice) {
        self.model = model
        self.mesh = mesh
        self.modelUniformBuffer = device.makeBuffer(length: MemoryLayout<ModelUniforms>.size, options: [])
        
        super.init()
    }

    func render(encoder: MTLRenderCommandEncoder) {
        self.modelUniforms.modelMatrix = self.model.modelMatrix
        
        let pModelUniformBuffer = self.modelUniformBuffer.contents()
        memcpy(pModelUniformBuffer, &self.modelUniforms, MemoryLayout<ModelUniforms>.size)

        encoder.setVertexBuffer(self.modelUniformBuffer, offset: 0, at: BufferIndex.ModelUniformBuffer.rawValue)
        
        self.mesh.render(encoder: encoder)
    }
    
}
