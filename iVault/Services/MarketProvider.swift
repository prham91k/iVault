//
//  MarketProvider.swift
//  XWallet
//
//  Created by loj on 23.03.18.
//

import Foundation

public protocol MarketProviderProtocol {
    func getTicker()->String
    func getEndPoint()->String
    func getURL(currency: String)->URL
    func getFiatEquivalent(forCurrency currency: String,
                           completionHandler: @escaping (_ factor: Double, _ currency: String) -> Void,
                           failedHandler: @escaping () -> Void)
}


public class MarketProvider: MarketProviderProtocol {
   
    public init() {
        
    }
    public func getTicker() -> String {
        return "XLA"
    }
    public func getEndPoint() -> String {
        return "";
    }
    
    
    public func getURL(currency: String) -> URL {
        
        
        let uri = String(format: self.getEndPoint(), self.getTicker(), currency)
        Debug.print(s: "Fetch full URL \(uri)");
        let url = URL(string: uri)!
        return url
    }
    
    public func getFiatEquivalent(forCurrency currency: String,
                                  completionHandler: @escaping (_ factor: Double, _ currency: String) -> Void,
                                  failedHandler: @escaping () -> Void)
    {
        
        let url = self.getURL(currency: currency);
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                Debug.print(s:error.localizedDescription)
            }else if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    if let json = jsonResponse
                    {
                        if let node = json[self.getTicker()] as? [String:Any]
                        {
                            
                            let currencyLowerCase = currency.lowercased()
                            let currencyUpperCase = currency.uppercased()
                            if let fiatValue = node[currency] as? String{
                                let convertedValue = Double(fiatValue)
                                Debug.print(s: "Currency value \(String(describing: convertedValue)) \(currency)")
                                completionHandler(convertedValue ?? 0.00, currency)
                                return
                            }else if let fiatValue = node[currency] as? Double{
                                Debug.print(s: "Currency value \(String(describing: fiatValue)) \(currency)")
                                completionHandler(fiatValue, currency)
                                return
                            }
                            if let fiatValue = node[currencyLowerCase] as? String{
                                let convertedValue = Double(fiatValue)
                                Debug.print(s: "Currency value \(String(describing: convertedValue)) \(currencyLowerCase)")
                                completionHandler(convertedValue ?? 0.00, currency)
                                return
                            } else if let fiatValue = node[currencyLowerCase] as? Double{
                                Debug.print(s: "Currency value \(String(describing: fiatValue)) \(currencyLowerCase)")
                                completionHandler(fiatValue, currency)
                                return
                            }
                            if let fiatValue = node[currencyUpperCase] as? String{
                                let convertedValue = Double(fiatValue)
                                Debug.print(s: "Currency value \(String(describing: convertedValue)) \(currencyUpperCase)")
                                completionHandler(convertedValue ?? 0.00, currency)
                                return
                            }else if let fiatValue = node[currencyUpperCase] as? Double{
                                Debug.print(s: "Currency value \(String(describing: fiatValue)) \(currencyLowerCase)")
                                completionHandler(fiatValue, currency)
                                return
                            }
                            Debug.print(s: "Node key for currency not avaliable \(node) \(currency)")
                        } else {
                            Debug.print(s: "Unable to return node response")
                        }
                    } else {
                        Debug.print(s: "Unable to return response")
                    }
                }  catch let error as NSError {
                    Debug.print(s:error.localizedDescription)
                } catch {
                    Debug.print(s: "Error fetching data \(String(describing: response))")
                }
            } else {
                Debug.print(s: "Error response data \(String(describing: response))")
            }
            failedHandler()
        }
        
        task.resume()
    }
}
