//
//  ShaderTypes.swift
//  Visualiser
//
//  Created by Douglas Finlay on 11/01/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import simd

struct FrameUniforms {
    var viewMatrix: float4x4
    var projectionMatrix: float4x4
}

struct MaterialUniforms {
    var diffuseColor: float4      = [0.0, 0.0, 0.0, 1.0]
    var specularColor: float4     = [0.0, 0.0, 0.0, 1.0]
    
    var specularIntensity: Float  = 0.0
    var pad1: Float = 0.0
    var pad2: Float = 0.0
    var pad3: Float = 0.0
}
