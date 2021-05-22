//
//  InteropConverter.swift
//  XWallet
//
//  Created by loj on 03.12.17.
//

import Foundation


public class InteropConverter {
    
    public static func convert<T>(data: UnsafePointer<T>, elementCount: Int) -> [T] {
        //let buffer = UnsafeBufferPointer(start: data, count: count)
        let buffer = data.withMemoryRebound(to: T.self, capacity: 1) {
            UnsafeBufferPointer(start: $0, count: elementCount)
        }
        
        return Array(buffer)
    }
}
