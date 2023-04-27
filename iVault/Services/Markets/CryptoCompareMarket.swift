//
//  CryptoCompareMarket.swift
//  iVault
//
//  Created by Azizul Hakimi Mohd Yussuf Izzudin on 25/04/2023.
//  Copyright © 2023 loj. All rights reserved.
//

import Foundation

class CryptoCompareMarket: MarketProvider {
    
    override func getEndPoint() -> String {
        return "https://min-api.cryptocompare.com/data/pricemulti?fsyms=%@&tsyms=%@"
    }
}
