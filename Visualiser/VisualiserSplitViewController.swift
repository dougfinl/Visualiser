//
//  VisualiserSplitViewController.swift
//  Visualiser
//
//  Created by Douglas Finlay on 17/02/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Cocoa

class VisualiserSplitViewController: NSSplitViewController {
    
    var metalViewController: MetalViewController! = nil
    
    var inspectorViewController: InspectorViewController! = nil
    
    var inspectorSplitViewItem: NSSplitViewItem! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metalViewController     = childViewControllers[0] as! MetalViewController
        inspectorViewController = childViewControllers[1] as! InspectorViewController
        
        inspectorSplitViewItem  = splitViewItem(for: inspectorViewController)
        inspectorSplitViewItem.isCollapsed = true
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
                self.metalViewController.loadModel(fromFile: fileURL)
            }
        }
    }
    
    @IBAction func toggleInspector(sender: AnyObject) {
        inspectorSplitViewItem.animator().isCollapsed = !inspectorSplitViewItem.animator().isCollapsed
    }
    
    @IBAction override func selectAll(_ sender: Any?) {
        print("WARNING: selectAll not yet implemented")
    }
    
    @IBAction func deselectAll(_ sender: Any?) {
        print("WARNING: deselectAll not yet implemented")
    }
    
}
