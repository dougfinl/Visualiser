//
//  VisualiserViewController.swift
//  Visualiser
//
//  Created by Douglas Finlay on 17/02/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Cocoa

class VisualiserViewController: NSSplitViewController {
    
    override var representedObject: Any? {
        didSet {
            for viewController in self.childViewControllers {
                viewController.representedObject = representedObject
            }

            // The document has changed so recreate renderable models
            self.createRenderables()
        }
    }
    
    var metalViewController: MetalViewController! = nil
    
    var sidebarViewController: SidebarViewController! = nil
    
    var sidebarSplitViewItem: NSSplitViewItem! = nil
    
    @IBOutlet var modelsArrayController: NSArrayController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metalViewController   = childViewControllers[0] as! MetalViewController
        sidebarViewController = childViewControllers[1] as! SidebarViewController
        
        sidebarSplitViewItem  = splitViewItem(for: sidebarViewController)
        sidebarSplitViewItem.isCollapsed = true
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
                self.loadModel(fromURL: fileURL)
                
                // Show the sidebar
                if self.sidebarSplitViewItem.isCollapsed {
                    self.toggleInspector(sender: self)
                }
            }
        }
    }
    
    func createRenderables() {
        for m in (self.representedObject as! Show).stage.models {
            do {
                try metalViewController.createRenderableModel(forModel: m)
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
            try metalViewController.createRenderableModel(forModel: newModel)
        } catch {
            print("ERROR: could not create renderable for \(newModel.name)")
            return
        }
        
        modelsArrayController.addObject(newModel)
    }
    
    @IBAction func toggleInspector(sender: AnyObject) {
        sidebarSplitViewItem.animator().isCollapsed = !sidebarSplitViewItem.animator().isCollapsed
    }
    
    @IBAction override func selectAll(_ sender: Any?) {
        print("WARNING: selectAll not yet implemented")
    }
    
    @IBAction func deselectAll(_ sender: Any?) {
        print("WARNING: deselectAll not yet implemented")
    }
    
}
