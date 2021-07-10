//
//  FiatProvider.swift
//  XWallet
//
//  Created by loj on 23.03.18.
//

import Foundation

public protocol FiatProviderProtocol {
    func getFiatEquivalent(forCurrency currency: String,
                           completionHandler: @escaping (_ factor: Double, _ currency: String) -> Void,
                           failedHandler: @escaping () -> Void)
}


public class FiatProvider: FiatProviderProtocol {
    
    public init() {
    }
    
    public func getFiatEquivalent(forCurrency currency: String,
                                  completionHandler: @escaping (_ factor: Double, _ currency: String) -> Void,
                                  failedHandler: @escaping () -> Void)
    {
        let uri = String(format: Constants.fiatProviderUri, currency)
        let url = URL(string: uri)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    
                    if let json = jsonResponse
                        , let xmrNode = json["XLA"] as? [String:Any]
                        , let fiatValue = xmrNode[currency] as? Double
                    {
                        completionHandler(fiatValue, currency)
                        return
                    }
                }  catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
            failedHandler()
        }
        
        task.resume()
    }
}
