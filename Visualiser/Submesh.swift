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
    
    init(mtkSubmesh: MTKSubmesh, mdlSubmesh: MDLSubmesh, device: MTLDevice) {
        submesh = mtkSubmesh
    }
    
    func render(encoder: MTLRenderCommandEncoder) {
        encoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
    }
    
}
