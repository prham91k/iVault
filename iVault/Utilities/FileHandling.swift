//
//  FileHandling.swift
//  XWallet
//
//  Created by loj on 12.11.17.
//

import Foundation


public protocol FileHandlingProtocol {

    /// Document path
    ///
    /// - Returns: document folder path including trailing slash
    func documentPath() -> String
    
    func removeFile(pathWithFileName: String)

    func purge(wallet walletName: String)
}


public class FileHandling: FileHandlingProtocol {
    
    public func documentPath() -> String {
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = allPaths[0]
        return documentDirectory + "/"
    }
    
    public func removeFile(pathWithFileName: String) {
        do {
            try FileManager.default.removeItem(atPath: pathWithFileName)
        } catch let error as NSError {
            print("### unable to remove file '\(pathWithFileName)', got error '\(error.domain)'")
        }
    }
    
    public func purge(wallet walletName: String) {
        let documentPath = self.documentPath()
        let keysExtension = ".keys"
        let addressExtension = ".address.txt"
        self.removeFile(pathWithFileName: documentPath + walletName)
        self.removeFile(pathWithFileName: documentPath + walletName + keysExtension)
        self.removeFile(pathWithFileName: documentPath + walletName + addressExtension)
    }
}
