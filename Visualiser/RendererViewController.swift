//
//  RendererViewController.swift
//  Visualiser
//
//  Created by Douglas Finlay on 29/12/2016.
//  Copyright © 2016 Douglas Finlay. All rights reserved.
//

import MetalKit

class RendererViewController: NSViewController, NSWindowDelegate, MTKViewDelegate {
        
    var camera = ArcballCamera()
    
    let notificationCenter = NotificationCenter.default
    
    var renderer: MetalRenderer = MetalRenderer()
    
    @IBOutlet var modelsArrayController: NSArrayController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let v = self.view as? MTKView else {
            NSLog("could not cast view to MTKView")
            return
        }
        
        self.renderer.view = v
        v.delegate = self
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let drawableSize = view.drawableSize
        camera.viewportWidth = Float(drawableSize.width)
        camera.viewportHeight = Float(drawableSize.height)
        camera.update()
    }
    
    func draw(in view: MTKView) {
        renderer.update(camera: camera)
        renderer.render()
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

    func selectMesh(_ mesh: Mesh) {
        notificationCenter.post(name: Notification.Name(rawValue: "meshSelectionChanged"), object: nil, userInfo: ["selectedMesh":mesh])
    }
    
    func createRenderables() {
        for m in (self.representedObject as! Show).stage.models {
            do {
                try renderer.createRenderable(forModel: m)
            } catch {
                print("ERROR: could not create renderable for \(m.name)")
            }
        }
    }
    
    func loadModel(fromURL url: URL) {
        let path = url.standardizedFileURL.absoluteString
        let name = (path as NSString).lastPathComponent
        
        let newModel = Model()
        newModel.path = path
        newModel.name = name
        
        do {
            try renderer.createRenderable(forModel: newModel)
        } catch {
            print("ERROR: could not create renderable for \(newModel.name)")
            return
        }
        
        modelsArrayController.addObject(newModel)
    }
    
}
