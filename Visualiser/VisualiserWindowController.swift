//
//  VisualiserWindowController.swift
//  Visualiser
//
//  Created by Douglas Finlay on 03/03/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Cocoa

class VisualiserWindowController: NSWindowController {
    
    override var document: AnyObject? {
        didSet {
            if let document = self.document as? NSDocument {
                self.contentViewController?.representedObject = document
            }
        }
    }
    
}
