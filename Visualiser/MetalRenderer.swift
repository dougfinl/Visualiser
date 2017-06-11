//
//  MetalRenderer.swift
//  Visualiser
//
//  Created by Douglas Finlay on 05/06/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import MetalKit

enum VertexAttributes: Int {
    case VertexAttributePosition = 0
    case VertexAttributeNormal
    case VertexAttributeTexCoord
}

enum TextureIndex: Int {
    case DiffuseTextureIndex = 0
}

enum BufferIndex: Int {
    case MeshVertexBuffer = 0
    case FrameUniformBuffer
    case MaterialUniformBuffer
    case ModelUniformBuffer
}

let MaxInflightBuffers = 3
let ConstantBufferSize = 1024*1024

class MetalRenderer {
    
    var view: MTKView? = nil {
        didSet {
            view!.device      = device
            view!.sampleCount = 1
            view!.clearColor  = MTLClearColorMake(0.5, 0.0, 0.5, 1.0)
            view!.colorPixelFormat        = .bgra8Unorm
            view!.depthStencilPixelFormat = .depth32Float_stencil8
        }
    }
    
    var device: MTLDevice!   = nil
    var library: MTLLibrary! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var simpleScenePipelineState: MTLRenderPipelineState! = nil
    
    var frameUniformBuffer: MTLBuffer! = nil
    
    var modelManager: ModelManager! = nil
    
    var renderableModels = [RenderableModel]()
    
    private lazy var vertexDescriptor: MTLVertexDescriptor = {
        let desc = MTLVertexDescriptor()
        // Vertex
        desc.attributes[VertexAttributes.VertexAttributePosition.rawValue].format = .float3
        desc.attributes[VertexAttributes.VertexAttributePosition.rawValue].offset = 0
        desc.attributes[VertexAttributes.VertexAttributePosition.rawValue].bufferIndex = 0
        // Normal
        desc.attributes[VertexAttributes.VertexAttributeNormal.rawValue].format = .float3
        desc.attributes[VertexAttributes.VertexAttributeNormal.rawValue].offset = 12
        desc.attributes[VertexAttributes.VertexAttributeNormal.rawValue].bufferIndex = 0
        // Texture coord
        desc.attributes[VertexAttributes.VertexAttributeTexCoord.rawValue].format = .half2
        desc.attributes[VertexAttributes.VertexAttributeTexCoord.rawValue].offset = 24
        desc.attributes[VertexAttributes.VertexAttributeTexCoord.rawValue].bufferIndex = 0
        // Single interleaved buffer
        desc.layouts[0].stride = 28
        desc.layouts[0].stepRate = 1
        desc.layouts[0].stepFunction = .perVertex

        return desc
    }()
    
    private lazy var gBufferAlbedoTexture: MTLTexture = {
        guard let v = self.view else {
            fatalError("failed to set dimensions of geometry buffer albedo texture")
        }
        let width = Int(v.frame.size.width)
        let height = Int(v.frame.size.height)
        
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        desc.sampleCount = 1
        desc.storageMode = .private
        desc.textureType = .type2D
        desc.usage       = [.renderTarget, .shaderRead]
        
        return self.device.makeTexture(descriptor: desc)
    }()
    
    private lazy var gBufferNormalTexture: MTLTexture = {
        guard let v = self.view else {
            fatalError("failed to set dimensions of geometry buffer normal texture")
        }
        let width = Int(v.frame.size.width)
        let height = Int(v.frame.size.height)
        
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Float, width: width, height: height, mipmapped: false)
        desc.sampleCount = 1
        desc.storageMode = .private
        desc.textureType = .type2D
        desc.usage       = [.renderTarget, .shaderRead]
        
        return self.device.makeTexture(descriptor: desc)
    }()
    
    private lazy var gBufferPositionTexture: MTLTexture = {
        guard let v = self.view else {
            fatalError("failed to set dimensions of geometry buffer position texture")
        }
        let width = Int(v.frame.size.width)
        let height = Int(v.frame.size.height)
        
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Float, width: width, height: height, mipmapped: false)
        desc.sampleCount = 1
        desc.storageMode = .private
        desc.textureType = .type2D
        desc.usage       = [.renderTarget, .shaderRead]
        
        return self.device.makeTexture(descriptor: desc)
    }()
    
    private lazy var gBufferDepthTexture: MTLTexture = {
        guard let v = self.view else {
            fatalError("failed to set dimensions of geometry buffer depth texture")
        }
        let width = Int(v.frame.size.width)
        let height = Int(v.frame.size.height)
        
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: width, height: height, mipmapped: false)
        desc.sampleCount = 1
        desc.storageMode = .private
        desc.textureType = .type2D
        desc.usage       = [.renderTarget, .shaderRead]
        
        return self.device.makeTexture(descriptor: desc)
    }()
    
    private lazy var gBufferRenderPassDescriptor: MTLRenderPassDescriptor = {
        let desc = MTLRenderPassDescriptor()
        desc.colorAttachments[0].clearColor  = MTLClearColorMake(0.5, 0.0, 0.5, 1.0)
        desc.colorAttachments[0].texture     = self.gBufferAlbedoTexture
        desc.colorAttachments[0].loadAction  = .clear
        desc.colorAttachments[0].storeAction = .store
        
        desc.colorAttachments[1].texture     = self.gBufferNormalTexture
        desc.colorAttachments[1].loadAction  = .clear
        desc.colorAttachments[1].storeAction = .store
        
        desc.colorAttachments[2].texture     = self.gBufferPositionTexture
        desc.colorAttachments[2].loadAction  = .clear
        desc.colorAttachments[2].storeAction = .store
        
        desc.depthAttachment.loadAction  = .clear
        desc.depthAttachment.storeAction = .store
        desc.depthAttachment.texture     = self.gBufferDepthTexture
        desc.depthAttachment.clearDepth  = 1.0
        
        return desc
    }()
    
    private lazy var gBufferDepthStencilState: MTLDepthStencilState = {
        let desc = MTLDepthStencilDescriptor()
        desc.isDepthWriteEnabled = true
        desc.depthCompareFunction = .lessEqual
        
        return self.device.makeDepthStencilState(descriptor: desc)
    }()
    
    private lazy var gBufferRenderPipelineState: MTLRenderPipelineState = {
        let desc = MTLRenderPipelineDescriptor()
        desc.colorAttachments[0].pixelFormat = .rgba8Unorm
        desc.colorAttachments[1].pixelFormat = .rgba16Float
        desc.colorAttachments[2].pixelFormat = .rgba16Float
        desc.depthAttachmentPixelFormat      = .depth32Float
        desc.sampleCount      = 1
        desc.label            = "geometry buffer render pipeline"
        desc.vertexFunction   = self.library.makeFunction(name: "gBufferVertex")
        desc.fragmentFunction = self.library.makeFunction(name: "gBufferFragment")
        desc.vertexDescriptor = self.vertexDescriptor
        
        var state: MTLRenderPipelineState
        do {
            try state = self.device.makeRenderPipelineState(descriptor: desc)
        } catch let error {
            fatalError("Could not create geometry buffer pipeline state: \(error)")
        }
        
        return state
    }()
    
    private lazy var compositionTexture: MTLTexture = {
        guard let v = self.view else {
            fatalError("failed to set dimensions of composition texture")
        }
        let width = Int(v.frame.size.width)
        let height = Int(v.frame.size.height)
        
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: width, height: height, mipmapped: false)
        desc.sampleCount = 1
        desc.storageMode = .private
        desc.textureType = .type2D
        desc.usage       = [.renderTarget, .shaderRead]
        
        return self.device.makeTexture(descriptor: desc)
    }()
    
    private lazy var bufferCompositionRenderPassDescriptor: MTLRenderPassDescriptor = {
        let desc = MTLRenderPassDescriptor()
        desc.colorAttachments[0].clearColor  = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
        desc.colorAttachments[0].texture    = self.compositionTexture
        desc.colorAttachments[0].loadAction  = .clear
        desc.colorAttachments[0].storeAction = .store
        
        return desc
    }()
    
    private lazy var compositionRenderPipelineState: MTLRenderPipelineState = {
        let desc = MTLRenderPipelineDescriptor()
        desc.colorAttachments[0].pixelFormat = .bgra8Unorm
        desc.label            = "buffer composition render pipeline"
        desc.vertexFunction   = self.library.makeFunction(name: "compositionVertex")
        desc.fragmentFunction = self.library.makeFunction(name: "compositionFragment")
        
        var state: MTLRenderPipelineState
        do {
            try state = self.device.makeRenderPipelineState(descriptor: desc)
        } catch let error {
            fatalError("Could not create geometry buffer pipeline state: \(error)")
        }
        
        return state
    }()
    
    private lazy var compositionDepthStencilState: MTLDepthStencilState = {
        let desc = MTLDepthStencilDescriptor()
        desc.isDepthWriteEnabled  = false
        desc.depthCompareFunction = .always
        
        return self.device.makeDepthStencilState(descriptor: desc)
    }()
    
    struct QuadVertex {
        var position: (x:Float, y:Float) = (0, 0)
        var texCoord: (u:Float, v:Float) = (0, 0)
    }
    
    private lazy var fullscreenQuadVertexBuffer:MTLBuffer = {
        var quadVerts = Array(repeating: QuadVertex(), count: 6)
        quadVerts[0].position = (-1,1) // top left
        quadVerts[0].texCoord = (0,0)
        quadVerts[1].position = (1,1)  // top right
        quadVerts[1].texCoord = (1,0)
        quadVerts[2].position = (1,-1)  // bottom right
        quadVerts[2].texCoord = (1,1)
        quadVerts[3] = quadVerts[0]
        quadVerts[4] = quadVerts[2]
        quadVerts[5].position = (-1,-1) // bottom left
        quadVerts[5].texCoord = (0,1)
        
        return self.device.makeBuffer(bytes: quadVerts, length: MemoryLayout<Float>.size * 24, options:[])
    }()
    
    private lazy var postProcessRenderPipelineState: MTLRenderPipelineState = {
       let desc = MTLRenderPipelineDescriptor()
        desc.label = "post=process render pipeline"
        desc.colorAttachments[0].pixelFormat = .bgra8Unorm
        desc.depthAttachmentPixelFormat      = .depth32Float_stencil8
        desc.stencilAttachmentPixelFormat    = .depth32Float_stencil8
        desc.vertexFunction   = self.library.makeFunction(name: "postProcessVertex")
        desc.fragmentFunction = self.library.makeFunction(name: "postProcessFragment")
        desc.sampleCount      = 1
        
        var state: MTLRenderPipelineState
        do {
            try state = self.device.makeRenderPipelineState(descriptor: desc)
        } catch let error {
            fatalError("Could not create post-process pipeline state: \(error)")
        }
        
        return state
    }()
    
    init() {
        device = MTLCreateSystemDefaultDevice()
        
        guard device != nil else {
            NSLog("Metal is not supported on this device")
            return
        }
        
        frameUniformBuffer = device.makeBuffer(length: MemoryLayout<FrameUniforms>.size, options: [])
        frameUniformBuffer.label = "frame uniforms"
        
        commandQueue = device.makeCommandQueue()
        
        library = device.newDefaultLibrary()!
        
        modelManager = ModelManager(device: device, vertexDescriptor: vertexDescriptor)
    }
    
    func createRenderableModel(forModel model: Model) throws {
        if let renderableModel = modelManager.renderableModel(forModel: model) {
            renderableModels.append(renderableModel)
        } else {
            throw RenderableModelError.couldNotLoad
        }
    }
    
    func renderGBuffer(models: [RenderableModel], commandBuffer: MTLCommandBuffer) {
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: gBufferRenderPassDescriptor)
        encoder.label = "geometry buffer"
        encoder.setDepthStencilState(gBufferDepthStencilState)
        encoder.setFrontFacing(.counterClockwise)
        encoder.setCullMode(.back)
        encoder.setRenderPipelineState(gBufferRenderPipelineState)
        encoder.setVertexBuffer(frameUniformBuffer, offset: 0, at: 1)
        
        for model in models {
            model.render(encoder: encoder)
        }
        
        encoder.endEncoding()
    }
    
    func renderLightBuffer(commandBuffer: MTLCommandBuffer) {
        
    }
    
    func renderCombineBuffers(commandBuffer: MTLCommandBuffer) {
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: bufferCompositionRenderPassDescriptor)
        encoder.label = "deferred rendering composition"
        encoder.setRenderPipelineState(compositionRenderPipelineState)
        encoder.setDepthStencilState(compositionDepthStencilState)
        encoder.setVertexBuffer(fullscreenQuadVertexBuffer, offset: 0, at: 0)
        encoder.setFragmentTexture(gBufferAlbedoTexture, at: 0)
//        encoder.setFragmentTexture(lightBufferTexture, at: 1)
        encoder.setFragmentTexture(gBufferNormalTexture, at: 1)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        encoder.endEncoding()
    }
    
    func renderPostProcess(commandBuffer: MTLCommandBuffer, renderPassDescriptor: MTLRenderPassDescriptor) {
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        encoder.label = "post-processing"
        encoder.setRenderPipelineState(postProcessRenderPipelineState)
        encoder.setVertexBuffer(fullscreenQuadVertexBuffer, offset: 0, at: 0)
        encoder.setFragmentTexture(compositionTexture, at: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        encoder.endEncoding()
    }
    
    func render() {
        guard let v = self.view else {
            NSLog("no view attached to renderer")
            return
        }
        
        let commandBuffer = self.commandQueue.makeCommandBuffer()
        commandBuffer.label = "frame command buffer"
        
        // MARK: render the shadow buffer
        
        // MARK: render the G-buffer
        renderGBuffer(models: renderableModels, commandBuffer: commandBuffer)
        
        // MARK: render the light buffer
//        renderLightBuffer(commandBuffer: commandBuffer)
        
        // MARK: combine to create the final buffer
        renderCombineBuffers(commandBuffer: commandBuffer)
        
        guard let rpd = v.currentRenderPassDescriptor else {
            NSLog("failed to get rpd from view")
            return
        }
        
        // MARK: post-processing
        renderPostProcess(commandBuffer: commandBuffer, renderPassDescriptor: rpd)
        
        commandBuffer.present(v.currentDrawable!)
        commandBuffer.commit()
    }
    
    func update(camera: Camera) {
        let pFrameUniforms = frameUniformBuffer.contents()
        var frameUniforms = FrameUniforms(viewMatrix: camera.viewMatrix,
                                     projectionMatrix: camera.projectionMatrix)
        memcpy(pFrameUniforms, &frameUniforms, MemoryLayout<FrameUniforms>.size)
        
        for m in renderableModels {
            m.update(camera: camera)
        }
    }
    
}
