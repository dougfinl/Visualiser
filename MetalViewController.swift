//
//  MetalViewController.swift
//  Visualiser
//
//  Created by Douglas Finlay on 29/12/2016.
//  Copyright © 2016 Douglas Finlay. All rights reserved.
//

import Cocoa
import MetalKit

let MaxInflightBuffers = 3

class MetalViewController: NSViewController, MTKViewDelegate {
    
    var device: MTLDevice! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    
    let inflightSemaphore = DispatchSemaphore(value: MaxInflightBuffers)
    var bufferIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMetal()
    }
    
    func initMetal() {
        device = MTLCreateSystemDefaultDevice()
        
        guard device != nil else {
            NSLog("Metal is not supported on this device")
            self.view = NSView(frame: self.view.frame)
            
            return
        }
        
        let view = self.view as! MTKView
        view.delegate = self
        view.device = device
        view.sampleCount = 4
        
        loadAssets()
    }
    
    func loadAssets() {
        // let view = self.view as! MTKView
        
        commandQueue = device.makeCommandQueue()
        commandQueue.label = "main command queue"
        
        // let defaultLibrary = device.newDefaultLibrary()!
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Layout, size or resolution changed
    }
    
    func draw(in view: MTKView) {
        let _ = inflightSemaphore.wait(timeout: .distantFuture)
        
        update()
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.label = "frame command buffer"
        
        commandBuffer.addCompletedHandler {
            [weak self] commandBuffer in
            if let strongSelf = self {
                strongSelf.inflightSemaphore.signal()
            }
            return
        }
        
        // MARK: render frame
        if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {
            renderPassDescriptor.colorAttachments[0].resolveTexture = currentDrawable.texture
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0.5, blue: 0.5, alpha: 1)
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderEncoder.label = "render encoder"
            
            renderEncoder.pushDebugGroup("drawing clear colour")
            
            // Draw here
            
            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()
            
            commandBuffer.present(currentDrawable)
        }
        
        // bufferIndex matches the current semaphore controled frame index to ensure writing occurs at the correct region in the vertex buffer
        bufferIndex = (bufferIndex + 1) % MaxInflightBuffers
        
        commandBuffer.commit()
    }
    
    func update() {
        
    }
    
}
