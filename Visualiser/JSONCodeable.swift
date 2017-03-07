//
//  JSONCodeable.swift
//  Visualiser
//
//  Created by Douglas Finlay on 07/03/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Foundation

protocol JSONCodeable {
    
    init(json: [String:Any]) throws
    
    func json() -> [String:Any]
    
}

enum JSONCodingError: Error {
    case missing(String)
//    case invalid(String, Any)
}
