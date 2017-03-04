//
//  SidebarViewController.swift
//  Visualiser
//
//  Created by Douglas Finlay on 03/03/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Cocoa

class SidebarViewController: NSSplitViewController {
    
    override var representedObject: Any? {
        didSet {
            for viewController in self.childViewControllers {
                viewController.representedObject = representedObject
            }
        }
    }
    
    var outlinerViewController: OutlinerViewController! = nil
    
    var meshInspectorViewController: MeshInspectorViewController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlinerViewController = childViewControllers[0] as! OutlinerViewController
        meshInspectorViewController = childViewControllers[1] as! MeshInspectorViewController
    }
    
}
