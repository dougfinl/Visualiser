//
//  Utils.swift
//  Visualiser
//
//  Created by Douglas Finlay on 04/01/2017.
//  Copyright © 2017 Douglas Finlay. All rights reserved.
//

import simd

let M_PI_F = Float(M_PI)


func radians(fromDegrees theta: Float) -> Float {
    return theta * M_PI_F/180.0
}

func degrees(fromRadians theta: Float) -> Float {
    return theta * 180.0/M_PI_F
}

func identity() -> float4x4 {
    let X = float4(1.0, 0.0, 0.0, 0.0)
    let Y = float4(0.0, 1.0, 0.0, 0.0)
    let Z = float4(0.0, 0.0, 1.0, 0.0)
    let W = float4(0.0, 0.0, 0.0, 1.0)
    
    return float4x4([X, Y, Z, W])
}

func scale(x: Float, y: Float, z: Float) -> float4x4 {
    let X = float4(x, 0.0, 0.0, 0.0)
    let Y = float4(0.0, y, 0.0, 0.0)
    let Z = float4(0.0, 0.0, z, 0.0)
    let W = float4(0.0, 0.0, 0.0, 1.0)
    
    return float4x4([X, Y, Z, W])
}

func translate(x: Float, y: Float, z: Float) -> float4x4 {
    let X = float4(1.0, 0.0, 0.0, 0.0)
    let Y = float4(0.0, 1.0, 0.0, 0.0)
    let Z = float4(0.0, 0.0, 1.0, 0.0)
    let W = float4(x, y, z, 1.0)
    
    return float4x4([X, Y, Z, W])
}

func rotate(x: Float) -> float4x4 {
    let X = float4(1.0, 0.0, 0.0, 0.0)
    let Y = float4(0.0, cos(x), sin(x), 0.0)
    let Z = float4(0.0, -sin(x), cos(x), 0.0)
    let W = float4(0.0, 0.0, 0.0, 1.0)
    
    return float4x4([X, Y, Z, W])
}

func rotate(y: Float) -> float4x4 {
    let X = float4(cos(y), 0.0, -sin(y), 0.0)
    let Y = float4(0.0, 1.0, 0.0, 0.0)
    let Z = float4(sin(y), 0.0, cos(y), 0.0)
    let W = float4(0.0, 0.0, 0.0, 1.0)
    
    return float4x4([X, Y, Z, W])
}

func rotate(z: Float) -> float4x4 {
    let X = float4(cos(z), -sin(z), 0.0, 0.0)
    let Y = float4(-sin(z), cos(z), 0.0, 0.0)
    let Z = float4(0.0, 0.0, 1.0, 0.0)
    let W = float4(0.0, 0.0, 0.0, 1.0)
    
    return float4x4([X, Y, Z, W])
}

func lookAt(target: vector_float3, eye: vector_float3, up: vector_float3) -> float4x4 {
    let zAxis: vector_float3 = normalize(eye - target)
    let xAxis: vector_float3 = normalize(cross(up, zAxis))
    let yAxis: vector_float3 = cross(zAxis, xAxis)
    
    let X = float4(xAxis.x, yAxis.x, zAxis.x, 0.0)
    let Y = float4(xAxis.y, yAxis.y, zAxis.y, 0.0)
    let Z = float4(xAxis.z, yAxis.z, zAxis.z, 0.0)
    let W = float4(-dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1.0)
    
    return float4x4([X, Y, Z, W])
}

func perspectiveProjection(nearClip: Float, farClip: Float, aspect: Float, yFov: Float) -> float4x4 {
    let scaleY = 1 / tan(yFov * 0.5)
    let scaleX = scaleY / aspect
    let scaleZ = -(farClip + nearClip) / (farClip - nearClip)
    let scaleW = -2 * farClip * nearClip / (farClip - nearClip)
    
    let X = float4(scaleX, 0, 0, 0)
    let Y = float4(0, scaleY, 0, 0)
    let Z = float4(0, 0, scaleZ, -1)
    let W = float4(0, 0, scaleW, 0)
    
    return float4x4([X, Y, Z, W])
}
