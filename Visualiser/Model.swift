//
//  Model.swift
//  Visualiser
//
//  Created by Douglas Finlay on 06/03/2017.
//  Copyright © 2017 Douglas Finlay. All rights 

import Foundation
import simd

class Model: NSObject {
    
    var name: String = "New Model"
    
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

    func updateModelMatrix() {
        self.modelMatrix = translate(x: positionX, y: positionY, z: positionZ) * rotate(x: radians(fromDegrees: rotationX), y: radians(fromDegrees: rotationY), z: radians(fromDegrees: rotationZ)) * scale(x: mscale, y: mscale, z: mscale)
    }
    
}
