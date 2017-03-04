//
//  Mesh.swift
//  Visualiser
//
//  Created by Douglas Finlay on 08/01/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import MetalKit

class Mesh: NSObject {
    
    private var mesh: MTKMesh
    
    private var submeshes: [Submesh] = []
    
    var name: String
    
    var modelUniforms = ModelUniforms()
    var modelUniformBuffer: MTLBuffer! = nil
    
    var positionX: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    var positionY: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    var positionZ: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    
    var rotationX: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    var rotationY: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    var rotationZ: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    
    var mscale: Float = 1.0 {
        didSet {
            updateModelMatrix()
        }
    }
    
    var boundingBox: MDLAxisAlignedBoundingBox!
    
    init(mtkMesh: MTKMesh, mdlMesh: MDLMesh, device: MTLDevice) {
        mesh = mtkMesh
        
        assert(mtkMesh.submeshes.count == mdlMesh.submeshes!.count, "Number of submeshes in mtkMesh and mdlMesh does not match")
        
        mdlMesh.makeVerticesUnique()
        boundingBox = mdlMesh.boundingBox
        
        name = mtkMesh.name
        
        for i in 0..<mtkMesh.submeshes.count {
            let m = Submesh(mtkSubmesh: mtkMesh.submeshes[i],
                            mdlSubmesh: mdlMesh.submeshes![i] as! MDLSubmesh,
                            device: device)
            
            submeshes.append(m)
        }
        
        modelUniformBuffer = device.makeBuffer(length: MemoryLayout<ModelUniforms>.size, options: [])
    
        super.init()
        
        updateModelMatrix()
    }
    
    func updateModelMatrix() {
        
        modelUniforms.modelMatrix = translate(x: positionX, y: positionY, z: positionZ) * rotate(x: radians(fromDegrees: rotationX), y: radians(fromDegrees: rotationY), z: radians(fromDegrees: rotationZ)) * scale(x: mscale, y: mscale, z: mscale)
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        let pModelUniformBuffer = modelUniformBuffer.contents()
        memcpy(pModelUniformBuffer, &modelUniforms, MemoryLayout<ModelUniforms>.size)
        
        encoder.setVertexBuffer(modelUniformBuffer, offset: 0, at: BufferIndex.ModelUniformBuffer.rawValue)
        
        var bufferIndex = 0
        for vertexBuffer in mesh.vertexBuffers {
            encoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, at: bufferIndex)
            bufferIndex += 1
        }
        
        for submesh in submeshes {
            submesh.render(encoder: encoder)
        }
    }
    
}
