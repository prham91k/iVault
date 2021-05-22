//
//  PasswordGenerator.swift
//  XWallet
//
//  Created by loj on 09.02.18.
//

import Foundation


public class PasswordGenerator {
    
    private static let alphabet = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!$%&*_-=+?/.,<>@#")
    private static let alphabetLength = UInt32(alphabet.count)
    private static let passwordLength = 50
    
    public static func create() -> String {
        let password = String((0 ..< passwordLength)
            .map{ _ in alphabet[Int(arc4random_uniform(alphabetLength))] })
        return password
    }
}
