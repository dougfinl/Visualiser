//
//  Model.swift
//  Visualiser
//
//  Created by Douglas Finlay on 06/03/2017.
//  Copyright © 2017 Douglas Finlay. All rights 

import Foundation
import simd

class Model: NSObject, JSONCodeable {
    
    var name: String = "New Model"
    
    var path: String = ""
    
    var positionX: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    var positionY: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    var positionZ: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    
    var rotationX: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    var rotationY: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    var rotationZ: Float = 0.0 {
        didSet {
            updateModelMatrix()
        }
    }
    
    var mscale: Float = 1.0 {
        didSet {
            updateModelMatrix()
        }
    }
    
    var modelMatrix: float4x4 = identity()
    
    override init() {
        super.init()
        
        self.updateModelMatrix()
    }
    
    required init(json: [String:Any]) throws {
        super.init()
        
        guard let name = json["name"] as? String else {
            throw JSONCodingError.missing("name")
        }
        
        guard let path = json["path"] as? String else {
            throw JSONCodingError.missing("path")
        }
        
        let posX = json["posX"] as? Float
        let posY = json["posY"] as? Float
        let posZ = json["posZ"] as? Float
        
        let rotX = json["rotX"] as? Float
        let rotY = json["rotY"] as? Float
        let rotZ = json["rotZ"] as? Float
        
        let scale = json["scale"] as? Float
        
        self.name      = name
        self.path      = path
        self.positionX = posX  ?? 0.0
        self.positionY = posY  ?? 0.0
        self.positionZ = posZ  ?? 0.0
        self.rotationX = rotX  ?? 0.0
        self.rotationY = rotY  ?? 0.0
        self.rotationZ = rotZ  ?? 0.0
        self.mscale    = scale ?? 1.0
        
        self.updateModelMatrix()
    }
    
    func json() -> [String : Any] {
        var j = [String : Any]()
        j["name"]  = self.name
        j["path"]  = self.path
        j["posX"]  = self.positionX
        j["posY"]  = self.positionY
        j["posZ"]  = self.positionZ
        j["rotX"]  = self.rotationX
        j["rotY"]  = self.rotationY
        j["rotZ"]  = self.rotationZ
        j["scale"] = self.mscale
        
        return j
    }

    func updateModelMatrix() {
        self.modelMatrix = translate(x: positionX, y: positionY, z: positionZ) * rotate(x: radians(fromDegrees: rotationX), y: radians(fromDegrees: rotationY), z: radians(fromDegrees: rotationZ)) * scale(x: mscale, y: mscale, z: mscale)
    }
    
}
