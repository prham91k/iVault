//
//  EstimatedFeeProvider.swift
//  XWallet
//
//  Created by loj on 01.05.18.
//

import Foundation

public protocol FeeProviderProtocol {
    func getEstimatedFee(completionHandler: @escaping (_ feeInAtomicUnits: UInt64) -> Void,
                         failedHandler: @escaping () -> Void)
}


public class FeeProvider: FeeProviderProtocol {
    
    public init() {
    }
    
    public func getEstimatedFee(completionHandler: @escaping (UInt64) -> Void, failedHandler: @escaping () -> Void) {
        let request = self.buildRequest()
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    
                    if let json = jsonResponse
                        , let resultNode = json["result"] as? [String:Any]
                        , let feeValue = resultNode["fee"] as? UInt64
                    {
                        completionHandler(feeValue)
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
    
    private func buildRequest() -> URLRequest {
        let url = URL(string: Constants.feeProviderUri)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = self.requestBody()
        return request
    }
    
    private func requestBody() -> Data? {
        let content = ["jsonrpc": "2.0",
                       "method": "get_fee_estimate"]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: content, options: .sortedKeys)
            return jsonData
        } catch {
            return nil
        }
    }
}
