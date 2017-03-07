//
//  ModelManager.swift
//  Visualiser
//
//  Created by Douglas Finlay on 06/03/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import MetalKit

class ModelManager {
    
    private var meshStore = [Mesh]()
    
    private var device: MTLDevice
    
    private var mdlVertexDescriptor: MDLVertexDescriptor
    
    private var meshBufferAllocator: MTKMeshBufferAllocator
    
    init(device: MTLDevice, vertexDescriptor: MTLVertexDescriptor) {
        self.device = device
        
        self.meshBufferAllocator = MTKMeshBufferAllocator(device: self.device)
        
        self.mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        (mdlVertexDescriptor.attributes[VertexAttributes.VertexAttributePosition.rawValue] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (mdlVertexDescriptor.attributes[VertexAttributes.VertexAttributeNormal.rawValue] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        (mdlVertexDescriptor.attributes[VertexAttributes.VertexAttributeTexCoord.rawValue] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
    }
    
    // Loads a model from the specified URL. Returns nil if loading fails.
    //
    // TODO: this should not duplicate meshes already in the store
    func loadModel(fromURL url: URL) -> RenderableModel? {
        let path = url.standardizedFileURL.absoluteString
        
        print("Loading " + path)
        
        let asset = MDLAsset(url: url, vertexDescriptor: self.mdlVertexDescriptor, bufferAllocator: self.meshBufferAllocator)
        
        var mdlMeshes: NSArray? = NSArray.init()
        var mtkMeshes: [MTKMesh] = []
        
        do {
            try mtkMeshes = MTKMesh.newMeshes(from: asset, device: device, sourceMeshes: &mdlMeshes)
        } catch let error {
            print("ERROR: could not load mesh: \(error)")
            return nil
        }
        
        assert(mtkMeshes.count == mdlMeshes!.count, "mdlMesh and mtkMesh arrays differ in size")
        
        if mtkMeshes.count > 1 {
            print("ERROR: too many meshes loaded")
            return nil
        }
        
        let mesh = Mesh(mtkMesh: mtkMeshes[0], mdlMesh: mdlMeshes![0] as! MDLMesh, device: device)
        self.meshStore.append(mesh)
        
        let model = Model()
        model.name = url.deletingPathExtension().lastPathComponent
        model.path = path
        
        let renderableModel = RenderableModel(model: model, mesh: mesh, device: self.device)
        
        return renderableModel
    }
    
}
