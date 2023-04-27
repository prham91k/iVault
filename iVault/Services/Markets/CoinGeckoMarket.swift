//
//  CoinGeckoMarket.swift
//  iVault
//
//  Created by Azizul Hakimi Mohd Yussuf Izzudin on 25/04/2023.
//  Copyright © 2023 loj. All rights reserved.
//

import Foundation

class CoinGeckoMarket: MarketProvider {
    override func getTicker() -> String {
        return "stellite"
    }
    override func getEndPoint() -> String {
        return "https://api.coingecko.com/api/v3/simple/price?ids=%@&vs_currencies=%@"
    }
    public override init() {
    }
}
