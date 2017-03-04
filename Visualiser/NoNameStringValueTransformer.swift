//
//  NoNameStringValueTransformer.swift
//  Visualiser
//
//  Created by Douglas Finlay on 04/03/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Cocoa

@objc(NoNameStringValueTransformer) class NoNameStringValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let str = value as? NSString else {
            return ""
        }
        
        if str == "No Name" {
            return ""
        }
        
        return str
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let str = value as? NSString else {
            return "No Name"
        }
        
        if str == "" {
            return "No Name"
        }
        
        return str
    }

}
