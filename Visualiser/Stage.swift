//
//  Stage.swift
//  Visualiser
//
//  Created by Douglas Finlay on 03/03/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import Cocoa

class Stage: NSObject, JSONCodeable {
    
    var models = [Model]()
    
    var modelSelectionIndexes = NSIndexSet()
    
    override init() {
        super.init()
    }
    
    required init(json: [String : Any]) throws {
        super.init()
        
        guard let modelsJSONArray = json["models"] as? [[String : Any]] else {
            throw JSONCodingError.missing("models")
        }
        
        var models = [Model]()
        for modelJSON in modelsJSONArray {
            let m = try Model(json: modelJSON)
            models.append(m)
        }
        self.models = models
    }
    
    func json() -> [String : Any] {
        var j = [String : Any]()
        
        var modelsJSONArray = [[String : Any]]()
        for m in models {
            modelsJSONArray.append(m.json())
        }
        j["models"] = modelsJSONArray
        
        return j
    }

}
