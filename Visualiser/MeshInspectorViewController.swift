//
//  MeshInspectorViewController.swift
//  Visualiser
//
//  Created by Douglas Finlay on 18/02/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Cocoa

class MeshInspectorViewController: NSViewController, NSTextViewDelegate {
    
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtPositionX: NSTextField!
    @IBOutlet weak var txtPositionY: NSTextField!
    @IBOutlet weak var txtPositionZ: NSTextField!
    @IBOutlet weak var txtRotationX: NSTextField!
    @IBOutlet weak var txtRotationY: NSTextField!
    @IBOutlet weak var txtRotationZ: NSTextField!
    @IBOutlet weak var txtScale: NSTextField!
    
    weak var mesh: Mesh? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resetFields()
    }
    
    func updateUI() {
        guard let m = mesh else {
            resetFields()
            return
        }

        txtName.stringValue     = m.name
        txtPositionX.floatValue = m.position.x
        txtPositionY.floatValue = m.position.y
        txtPositionZ.floatValue = m.position.z
        txtRotationX.floatValue = m.rotation.x
        txtRotationY.floatValue = m.rotation.y
        txtRotationZ.floatValue = m.rotation.z
        txtScale.floatValue     = m.mscale
    }
    
    func resetFields() {
        txtName.stringValue     = ""
        txtPositionX.floatValue = 0.0
        txtPositionY.floatValue = 0.0
        txtPositionZ.floatValue = 0.0
        txtRotationX.floatValue = 0.0
        txtRotationY.floatValue = 0.0
        txtRotationZ.floatValue = 0.0
        txtScale.floatValue     = 0.0
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        guard let o = obj.object as? NSTextField,
            let m = mesh else {
            return
        }
        
        switch (o) {
        case txtName:
            m.name = o.stringValue
        case txtPositionX:
            m.position.x = o.floatValue
        case txtPositionY:
            m.position.y = o.floatValue
        case txtPositionZ:
            m.position.z = o.floatValue
        case txtRotationX:
            m.rotation.x = radians(fromDegrees: o.floatValue)
        case txtRotationY:
            m.rotation.y = radians(fromDegrees: o.floatValue)
        case txtRotationZ:
            m.rotation.z = radians(fromDegrees: o.floatValue)
        case txtScale:
            m.mscale = o.floatValue
        default:
            print("WARNING: unknown control text changed in mesh inspector")
            break
        }
    }
    
}
