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
            rendererViewController.createRenderables()
        }
    }
    
    var rendererViewController: RendererViewController! = nil
    
    var sidebarViewController: SidebarViewController! = nil
    
    var sidebarSplitViewItem: NSSplitViewItem! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rendererViewController = childViewControllers[0] as! RendererViewController
        sidebarViewController  = childViewControllers[1] as! SidebarViewController
        
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
                self.rendererViewController.loadModel(fromURL: fileURL)
                
                // Show the sidebar
                if self.sidebarSplitViewItem.isCollapsed {
                    self.toggleInspector(sender: self)
                }
            }
        }
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
