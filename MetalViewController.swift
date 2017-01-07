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
let ConstantBufferSize = 1024*1024

let cubeVertexData: [Float] = [
    -0.5,  0.5,  0.5, 1.0,
    -0.5, -0.5,  0.5, 1.0,
     0.5, -0.5,  0.5, 1.0,
     
     0.5, -0.5,  0.5, 1.0,
     0.5,  0.5,  0.5, 1.0,
    -0.5,  0.5,  0.5, 1.0
]

let cubeColorData: [Float] = [
    1.0, 1.0, 1.0, 1.0,
    1.0, 1.0, 1.0, 1.0,
    1.0, 1.0, 1.0, 1.0,
    
    1.0, 1.0, 1.0, 1.0,
    1.0, 1.0, 1.0, 1.0,
    1.0, 1.0, 1.0, 1.0
]

struct Uniforms {
    var viewMatrix: float4x4
    var projectionMatrix: float4x4
}

class MetalViewController: NSViewController, MTKViewDelegate, NSWindowDelegate {
    
    var device: MTLDevice! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var simpleScenePipelineState: MTLRenderPipelineState! = nil
    
    var vertexBuffer: MTLBuffer! = nil
    var vertexColorBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    
    let inflightSemaphore = DispatchSemaphore(value: MaxInflightBuffers)
    var bufferIndex = 0
    
    var camera: ArcballCamera! = nil
    
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
        let view = self.view as! MTKView
        
        commandQueue = device.makeCommandQueue()
        commandQueue.label = "main command queue"
        
        // MARK: load shaders
        let defaultLibrary = device.newDefaultLibrary()!
        
        let simpleSceneVertexFunction = defaultLibrary.makeFunction(name: "simpleSceneVertex")!
        let simpleSceneFragmentFunction = defaultLibrary.makeFunction(name: "simpleSceneFragment")!
        
        let simpleScenePipelineStateDescriptor = MTLRenderPipelineDescriptor()
        simpleScenePipelineStateDescriptor.vertexFunction = simpleSceneVertexFunction
        simpleScenePipelineStateDescriptor.fragmentFunction = simpleSceneFragmentFunction
        simpleScenePipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        simpleScenePipelineStateDescriptor.sampleCount = view.sampleCount
        
        do {
            try simpleScenePipelineState = device.makeRenderPipelineState(descriptor: simpleScenePipelineStateDescriptor)
        } catch let error {
            NSLog("Failed to make simple scene pipeline state: \(error)")
        }
        
        vertexBuffer = device.makeBuffer(length: ConstantBufferSize, options: [])
        vertexBuffer.label = "vertices"
        
        let vertexColorSize = cubeVertexData.count * MemoryLayout<Float>.size
        vertexColorBuffer = device.makeBuffer(bytes: cubeColorData, length: vertexColorSize, options: [])
        vertexColorBuffer.label = "colors"
        
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: [])
        uniformBuffer.label = "uniforms"
        
        // MARK: initialise the camera
        let drawableSize = view.drawableSize
        camera = ArcballCamera()
        camera.viewportWidth = Float(drawableSize.width)
        camera.viewportHeight = Float(drawableSize.height)
        camera.update()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let drawableSize = view.drawableSize
        camera.viewportWidth = Float(drawableSize.width)
        camera.viewportHeight = Float(drawableSize.height)
        camera.update()
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
           
            renderEncoder.pushDebugGroup("drawing cube")
            renderEncoder.setRenderPipelineState(simpleScenePipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 256*bufferIndex, at: 0)
            renderEncoder.setVertexBuffer(vertexColorBuffer, offset: 0, at: 1)
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 2)
            renderEncoder.setFrontFacing(.counterClockwise)
            renderEncoder.setCullMode(.back)
            
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 9, instanceCount: 1)
            
            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()
            
            commandBuffer.present(currentDrawable)
        }
        
        // bufferIndex matches the current semaphore controled frame index to ensure writing occurs at the correct region in the vertex buffer
        bufferIndex = (bufferIndex + 1) % MaxInflightBuffers
        
        commandBuffer.commit()
    }
    
    func update() {
        let pData = vertexBuffer.contents()
        let vData = (pData + 256 * bufferIndex).bindMemory(to: Float.self, capacity: 256 / MemoryLayout<Float>.stride)
        
        vData.initialize(from: cubeVertexData)
                
        // MARK: fill the uniform buffer
        let pUniforms = uniformBuffer.contents()
        var uniforms = Uniforms(viewMatrix: camera.viewMatrix,
                                projectionMatrix: camera.projectionMatrix)
        memcpy(pUniforms, &uniforms, MemoryLayout<Uniforms>.size)
    }
    
    override public func mouseDragged(with event: NSEvent) {
        camera.heading -= Float(event.deltaX / 2.0)
        camera.pitch -= Float(event.deltaY / 2.0)
        camera.update()
    }
    
    override public func scrollWheel(with event: NSEvent) {
        camera.radius -= Float(event.scrollingDeltaY / 20.0)
        camera.update()
    }
    
}
