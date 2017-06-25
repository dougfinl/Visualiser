//
//  Lighting.swift
//  Visualiser
//
//  Created by Douglas Finlay on 11/06/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import simd

class DirectionalLight {
    
    var direction: float3 = [0.0, 0.0, 0.0] {
        didSet {
            _dirty = true
        }
    }
    
    var color: float3 = [1.0, 1.0, 1.0] {
        didSet {
            _dirty = true
        }
    }
    
    private var _dirty: Bool = true
    
    var isDirty: Bool {
        get {
            if _dirty {
                _dirty = false
                return true
            } else {
                return false
            }
        }
    }
    
}
