//
//  Camera.swift
//  Visualiser
//
//  Created by Douglas Finlay on 05/01/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import simd

protocol Camera {
    
    var projectionMatrix: float4x4 { get }
    var viewMatrix: float4x4 { get }
    
}

class ArcballCamera: Camera {
    
    var projectionMatrix: float4x4
    var viewMatrix: float4x4
    
    var viewportWidth: Float
    var viewportHeight: Float
    
    var target: float3
    var radius: Float
    
    var heading: Float
    var pitch: Float
    
    var nearClip: Float
    var farClip: Float
    
    var fov: Float
    
    private var position: float3
    private var up: float3
    
    init() {
        projectionMatrix = identity()
        viewMatrix = identity()
        viewportWidth = 1024
        viewportHeight = 1024
        target = [0, 0, 0]
        radius = 10
        heading = 0
        pitch = 0
        nearClip = 1
        farClip = 100
        fov = 90
        
        position = [0, 0, 10]
        up = [0, 1, 0]
        
        update()
    }
    
    func update() {
        updateViewMatrix()
        updateProjectionMatrix()
    }
    
    private func updateViewMatrix() {
        // Calculate position of camera
        let pitchTransform = rotate(x: radians(fromDegrees: pitch))
        let headingTransform = rotate(y: radians(fromDegrees: heading))
        let radiusTransform = translate(x: 0.0, y: 0.0, z: radius)
        
        let finalTransform = headingTransform * pitchTransform * radiusTransform
        let tmp = finalTransform * float4([0.0, 0.0, 0.0, 1.0])
        
        position.x = tmp.x
        position.y = tmp.y
        position.z = tmp.z
        
        viewMatrix = lookAt(target: target, eye: position, up: up)
    }
    
    private func updateProjectionMatrix() {
        projectionMatrix = perspectiveProjection(nearClip: nearClip, farClip: farClip, aspect: viewportWidth/viewportHeight, yFov: fov)
    }
    
}
