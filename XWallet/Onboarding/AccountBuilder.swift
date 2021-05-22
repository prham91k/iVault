////
////  KeyGenerator.swift
////  XWallet
////
////  Created by loj on 06.08.17.
////
//
//import Foundation
//
//
//public protocol AccountBuilderProtocol {
//    
//    func fromScratch() -> (spendKey: KeyPair, viewKey: KeyPair, publicAddress: String)
//    func fromSeed(_ seed: Seed) -> (spendKey: KeyPair, viewKey: KeyPair, publicAddress: String)
//    
//}
//
//
//public class AccountBuilder: AccountBuilderProtocol {
//    
//    private let recoveryBuilder: RecoveryBuilderProtocol!
//    
//    
//    public init(recoveryBuilder: RecoveryBuilderProtocol) {
//        self.recoveryBuilder = recoveryBuilder
//    }
//    
//    
//    public func fromScratch() -> (spendKey: KeyPair, viewKey: KeyPair, publicAddress: String) {
//        createAccountFromScratch()
//        
//        
//        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentDirectory = allPaths[0] + "/wallet2208"
//        print(documentDirectory)
//        
////        let fm = FileManager.default
////        let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
////        let myurl = docsurl.appendingPathComponent("wallet2208")
////        let documentDirectory = myurl.absoluteString
////        print(documentDirectory)
//        
//        let fileWithPathName = UnsafePointer<Int8>(documentDirectory)
//        createWalletManager(fileWithPathName)
//
//        return self.getAccount()
//    }
//    
//    
//    public func fromSeed(_ seed: Seed) -> (spendKey: KeyPair, viewKey: KeyPair, publicAddress: String) {
//        let key = self.recoveryBuilder.fromMnemonicSeed(seed).generate()
//        // TODO: (loj) refactor explicit wrapping
//        let moneroKey = makeMoneroKey(key!)
//        
//        recoverAccountFromPrivateSpendKey(moneroKey)
//
//        return self.getAccount()
//    }
//    
//    
//    private func getAccount() -> (spendKey: KeyPair, viewKey: KeyPair, publicAddress: String) {
//        let privateSpendKey = makeKey(getPrivateSpendKey())
//        let publicSpendKey = makeKey(getPublicSpendKey())
//        let privateViewKey = makeKey(getPrivateViewKey())
//        let publicViewKey = makeKey(getPublicViewKey())
//        
//        let viewKeyPair = KeyPair(privateKey: privateViewKey, publicKey: publicViewKey)
//        let spendKeyPair = KeyPair(privateKey: privateSpendKey, publicKey: publicSpendKey)
//        
//        let publicAddress = String(cString:getPublicAddress())
//        
//        return (spendKey: spendKeyPair, viewKey: viewKeyPair, publicAddress: publicAddress)
//    }
//    
//    
//    private func makeKey(_ moneroKey: MoneroKey) -> Key {
//        var keyData = [UInt8](repeatElement(0x00, count: Key.length))
//        var sourceData = moneroKey.keyData
//
//        memcpy(&keyData, &sourceData, keyData.count)
//        return Key(data: keyData)!
//    }
//    
//    
//    private func makeMoneroKey(_ key: Key) -> MoneroKey {
//        var moneroKey = MoneroKey()
//        
//        memcpy(&moneroKey, key.data, key.data.count)
//        return moneroKey
//    }
//}

