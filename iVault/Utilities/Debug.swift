//
//  Debug.swift
//  XWallet
//
//  Created by loj on 21.11.17.
//

import Foundation


public class Debug {
    
    public static func print(s: String) {
#if DEBUG
        Swift.print("[DEBUG]  \(s)")
#endif
    }
}
