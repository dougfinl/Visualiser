//
//  InspectorViewController.swift
//  Visualiser
//
//  Created by Douglas Finlay on 18/02/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Cocoa

class InspectorViewController: NSTabViewController {
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareInspectorNoSelection()
        nc.addObserver(forName: Notification.Name(rawValue: "meshSelectionChanged"), object: nil, queue: nil, using: updateInspectorSelection)
    }
    
    func updateInspectorSelection(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let selectedMesh = userInfo["selectedMesh"] as? Mesh else {
                print("WARNING: no user info in selection notification")
                prepareInspectorNoSelection()
                return
        }
        
        prepareInspector(mesh: selectedMesh)
    }
    
    func prepareInspectorNoSelection() {
        let index = tabView.indexOfTabViewItem(withIdentifier: "NoSelectionInspectorID")
        tabView.selectTabViewItem(at: index)
    }
    
    func prepareInspector(mesh: Mesh) {
        let index = tabView.indexOfTabViewItem(withIdentifier: "MeshInspectorID")
        tabView.selectTabViewItem(at: index)
    }
    
}
