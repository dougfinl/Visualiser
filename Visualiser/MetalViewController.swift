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
    
    var meshes: [Mesh] = []
    
    var camera: ArcballCamera! = nil
    
    var mtlVertexDescriptor: MTLVertexDescriptor! = nil
    
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
        
        // Create the pipeline vertex descriptor
        mtlVertexDescriptor = MTLVertexDescriptor()
        mtlVertexDescriptor.attributes[0].format = .float3
        mtlVertexDescriptor.attributes[0].offset = 0
        mtlVertexDescriptor.attributes[0].bufferIndex = 0
        
        mtlVertexDescriptor.attributes[1].format = .float3
        mtlVertexDescriptor.attributes[1].offset = 12
        mtlVertexDescriptor.attributes[1].bufferIndex = 0
        
        mtlVertexDescriptor.layouts[0].stride = 28      // FIXME: this value is incorrect
        mtlVertexDescriptor.layouts[0].stepRate = 1
        mtlVertexDescriptor.layouts[0].stepFunction = .perVertex
        
        let simpleScenePipelineStateDescriptor = MTLRenderPipelineDescriptor()
        simpleScenePipelineStateDescriptor.label = "SimpleScenePipeline"
        simpleScenePipelineStateDescriptor.vertexFunction = simpleSceneVertexFunction
        simpleScenePipelineStateDescriptor.fragmentFunction = simpleSceneFragmentFunction
        simpleScenePipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        simpleScenePipelineStateDescriptor.sampleCount = view.sampleCount
        simpleScenePipelineStateDescriptor.vertexDescriptor = mtlVertexDescriptor
        
        do {
            try simpleScenePipelineState = device.makeRenderPipelineState(descriptor: simpleScenePipelineStateDescriptor)
        } catch let error {
            NSLog("Failed to make simple scene pipeline state: \(error)")
        }
        
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
            renderEncoder.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(view.drawableSize.width), height: Double(view.drawableSize.height), znear: 0, zfar: 1))
            renderEncoder.setRenderPipelineState(simpleScenePipelineState)
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 2)
            renderEncoder.setFrontFacing(.counterClockwise)
            renderEncoder.setCullMode(.back)
            
            for mesh in meshes {
                mesh.render(encoder: renderEncoder)
            }
            
            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()
            
            commandBuffer.present(currentDrawable)
        }
        
        // bufferIndex matches the current semaphore controled frame index to ensure writing occurs at the correct region in the vertex buffer
        bufferIndex = (bufferIndex + 1) % MaxInflightBuffers
        
        commandBuffer.commit()
    }
    
    func update() {
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
    
    func loadModel(fromFile fileURL: URL) {
        NSLog("importing \(fileURL)")

        let mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(mtlVertexDescriptor)
        (mdlVertexDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (mdlVertexDescriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        
        let meshBufferAllocator = MTKMeshBufferAllocator(device: device)
        
        let asset = MDLAsset(url: fileURL, vertexDescriptor: mdlVertexDescriptor, bufferAllocator: meshBufferAllocator)
        
        var mdlMeshes: NSArray? = NSArray.init()
        var mtkMeshes: [MTKMesh] = []
        
        do {
            try mtkMeshes = MTKMesh.newMeshes(from: asset, device: device, sourceMeshes: &mdlMeshes)
        } catch let error {
            NSLog("error: failed to create mesh: \(error)")
            return
        }
        
        assert(mtkMeshes.count == mdlMeshes!.count, "mdlMesh and mtkMesh arrays differ in size")
        
        for (i, m) in mtkMeshes.enumerated() {
            let mesh = Mesh(mtkMesh: m, mdlMesh: mdlMeshes![i] as! MDLMesh, device: device)
            self.meshes.append(mesh)
        }
    }
    
    @IBAction func importMenuItemClicked(sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a 3D Model"
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["obj", "abc", "ply", "stl"]
        
        openPanel.begin { (result: Int) in
            if (result == NSFileHandlingPanelOKButton) {
                let fileURL = openPanel.url!
                self.loadModel(fromFile: fileURL)
            }
        }
    }
    
}
