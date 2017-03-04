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
        }
    }
    
    var metalViewController: MetalViewController! = nil
    
    var sidebarViewController: SidebarViewController! = nil
    
    var sidebarSplitViewItem: NSSplitViewItem! = nil
    
    @IBOutlet var meshesArrayController: NSArrayController!
    
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
                let loadedModels = self.metalViewController.loadModel(fromFile: fileURL)
                
                for m in loadedModels {
                    self.meshesArrayController.addObject(m)
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
