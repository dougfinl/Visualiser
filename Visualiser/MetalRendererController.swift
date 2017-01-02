//
//  MetalRenderer.swift
//  Visualiser
//
//  Created by Douglas Finlay on 29/12/2016.
//  Copyright © 2016 Douglas Finlay. All rights reserved.
//

import Cocoa
import MetalKit

class MetalRendererController: MTKView {
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        device = MTLCreateSystemDefaultDevice()
    }
    
    func render() {
        if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor {
            rpd.colorAttachments[0].texture = currentDrawable!.texture
            rpd.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0.5, blue: 0.5, alpha: 1)
            rpd.colorAttachments[0].loadAction = .clear
            let commandBuffer = device!.makeCommandQueue().makeCommandBuffer()
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd)
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        render()
    }
    
}
