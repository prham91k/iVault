//
//  Services.swift
//  XWallet
//
//  Created by loj on 21.11.17.
//

import Foundation


public protocol MoneroBagProtocol {
    
    var wallet: WalletProtocol? { get set }
    var payment: PaymentProtocol? { get set }
}


public class MoneroBag: MoneroBagProtocol {
    
    public var wallet: WalletProtocol?
    public var payment: PaymentProtocol?
    
}
