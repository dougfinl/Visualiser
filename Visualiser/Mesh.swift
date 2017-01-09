//
//  Mesh.swift
//  Visualiser
//
//  Created by Douglas Finlay on 08/01/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import MetalKit

class Mesh {
    
    private var mesh: MTKMesh
    
    private var submeshes: [Submesh] = []
    
    init(mtkMesh: MTKMesh, mdlMesh: MDLMesh, device: MTLDevice) {
        mesh = mtkMesh
        
        assert(mtkMesh.submeshes.count == mdlMesh.submeshes!.count, "Number of submeshes in mtkMesh and mdlMesh does not match")
        
        for i in 0..<mtkMesh.submeshes.count {
            let m = Submesh(mtkSubmesh: mtkMesh.submeshes[i],
                            mdlSubmesh: mdlMesh.submeshes![i] as! MDLSubmesh,
                            device: device)
            
            submeshes.append(m)
        }
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        var bufferIndex = 0
        
        for vertexBuffer in mesh.vertexBuffers {
            encoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, at: bufferIndex)
        }
        
        bufferIndex += 1
        
        for submesh in submeshes {
            submesh.render(encoder: encoder)
        }
    }
    
}
