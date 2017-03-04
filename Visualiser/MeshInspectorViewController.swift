//
//  MeshInspectorViewController.swift
//  Visualiser
//
//  Created by Douglas Finlay on 18/02/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Cocoa

class MeshInspectorViewController: NSViewController {
    
    @IBOutlet var meshArrayController: NSArrayController!
    
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtPositionX: NSTextField!
    @IBOutlet weak var txtPositionY: NSTextField!
    @IBOutlet weak var txtPositionZ: NSTextField!
    @IBOutlet weak var txtRotationX: NSTextField!
    @IBOutlet weak var txtRotationY: NSTextField!
    @IBOutlet weak var txtRotationZ: NSTextField!
    @IBOutlet weak var txtScale: NSTextField!
    
}
