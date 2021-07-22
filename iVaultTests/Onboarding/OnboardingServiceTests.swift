//
//  OnboardingServiceTests.swift
//  XWalletTests
//
//  Created by loj on 15.11.17.
//

import XCTest
import iVault


class OnboardingServiceTests: XCTestCase {
    
    private var testee: OnboardingService!
    private var walletBuilderMock: WalletBuilderMock!
    private var propertyStoreMock: PropertyStoreMock!
    private var secureStoreMock: SecureStoreMock!
    
    private static let documentDirectory = "someMockPath/"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.walletBuilderMock = WalletBuilderMock()
        self.propertyStoreMock = PropertyStoreMock(pin: nil, onboardingIsFinished: false)
        self.secureStoreMock = SecureStoreMock()
        
        self.testee = OnboardingService(walletBuilder: self.walletBuilderMock,
                                        propertyStore: self.propertyStoreMock,
                                        secureStore: self.secureStoreMock)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}


extension OnboardingServiceTests {

    func testCreateWallet_whenPinIsSet_butWalletNameNot_thenThrowsNoWalletName() {
        self.testee.setAppPin("some pin")
        
        XCTAssertThrowsError(try self.testee.createNewWallet()) { error in
            XCTAssertEqual(error as? WalletError, WalletError.noWalletName)
        }
    }
    
    func testCreateWallet_whenPinIsSetAndWalletNameIsSet_thenReturnsWallet() {
        self.testee.setAppPin("some pin")
        self.testee.setWalletName("some wallet name")
        
        guard let _ = try? self.testee.createNewWallet() else {
            XCTFail("failed to create wallet")
            return
        }
    }
}


extension OnboardingServiceTests {

    func testRecoverWallet_whenPinIsSet_butNoWalletNameSetAndNoSeedSet_thenThrowsNoWalletName() {
        self.testee.setAppPin("some pin")
        
        XCTAssertThrowsError(try self.testee.recoverWallet()) { error in
            XCTAssertEqual(error as? WalletError, WalletError.noWalletName)
        }
    }
    
    func testRecoverWallet_whenPinIsSetAndWalletNameIsSet_butNoSeedSet_thenThrowsNoSeed() {
        self.testee.setAppPin("some pin")
        self.testee.setWalletName("some wallet name")
        
        XCTAssertThrowsError(try self.testee.recoverWallet()) { error in
            XCTAssertEqual(error as? WalletError, WalletError.noSeed)
        }
    }

    func testRecoverWallet_whenPinIsSetAndWalletNameIsSetAndSeedIsSet_thenReturnsWallet() {
        self.testee.setAppPin("some pin")
        self.testee.setWalletName("some wallet name")
        self.testee.setSeed(self.getValidSeed())
        
        guard let _ = try? self.testee.createNewWallet() else {
            XCTFail("failed to recover wallet")
            return
        }
    }
}


extension OnboardingServiceTests {

    func testPurgeWallet_afterPurgeWithNoWalletNameGiven_propertyStoreIsUntouched() {
        self.propertyStoreMock.pin = "some pin"
        self.propertyStoreMock.onboardingIsFinished = true
        
        self.testee.purgeWallet()

        XCTAssertNotNil(self.propertyStoreMock.pin)
        XCTAssertTrue(self.propertyStoreMock.onboardingIsFinished)
    }
    
    func testPurgeWallet_afterPurge_onboardingStateIsReset() {
        self.secureStoreMock.walletPassword = "wallet password"
        self.propertyStoreMock.onboardingIsFinished = true
        let walletName = "2208"
        self.testee.setWalletName(walletName)
        try! self.testee.createNewWallet()

        self.testee.purgeWallet()

        XCTAssertNil(self.secureStoreMock.walletPassword)
        XCTAssertFalse(self.propertyStoreMock.onboardingIsFinished)
    }
}


extension OnboardingServiceTests {

    private func getValidSeed() -> Seed {
        return Seed(sentence: "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25")!
    }

    
    private class WalletBuilderMock: WalletBuilderProtocol {
        func withPassword(_ password: String, andWalletName walletName: String) -> WalletBuilderProtocol {
            return self
        }
        
        func withPin(_ pin: String, andWalletName walletName: String) -> WalletBuilderProtocol {
            return self
        }
        
        func fromScratch() -> WalletBuilderProtocol {
            return self
        }
        
        func fromSeed(_ seed: Seed) -> WalletBuilderProtocol {
            return self
        }
        
        func openExisting() throws -> WalletProtocol {
            return WalletMock()
        }
        
        func generate() throws -> WalletProtocol {
            return WalletMock()
        }
    }
    
    private class PropertyStoreMock: PropertyStoreProtocol {
        var lastFiatUpdate: Date?
        var lastFiatFactor: Double?
        var deprecatedAppPin: String?
        var language: String
        var currency: String
        var nodeAddress: String
        var pin: String?
        var onboardingIsFinished: Bool
        var feeInAtomicUnits: UInt64 = 0

        init(pin: String?, onboardingIsFinished: Bool) {
            self.pin = pin
            self.currency = "a currency"
            self.language = "a language"
            self.nodeAddress = "node address"
            self.onboardingIsFinished = onboardingIsFinished
        }
        
        func wipeAll() {
        }
    }
    
    private class SecureStoreMock: SecureStoreProtocol {
        var appPin: String?
        var walletPassword: String?
        var appleWatch2FAPassword: String?
        var nodeUserId: String = ""
        var nodePassword: String = ""
    }
    
    private class FileHandlingMock: FileHandlingProtocol {
        func documentPath() -> String {
            return documentDirectory
        }
        
        func removeFile(pathWithFileName: String) {
            self.deletedFiles.append(pathWithFileName)
        }
        
        var deletedFiles: [String] = []
    }
    
    private class WalletMock: WalletProtocol {
        
        public var purgeIsCalled = false
        
        func purge() {
            self.purgeIsCalled = true
        }
        
        func setNewPassword(_ password: String) {
        }
        
        func register(delegate: WalletDelegate) {
        }
        
        func unregisterDelegate() {
        }
        
        
        func connectToDaemon(address: String, upperTransactionSizeLimit: UInt64, daemonUsername: String, daemonPassword: String) {
        }
        
        func refreshWallet() {
        }
        
        func lock() {
        }
        
        func unlockWithPassword(_ password: String) {
        }
        
        init() {
            self.blockchainHeight = ""
            self.daemonBlockchainHeight = ""
            self.balance = 0
            self.unlockedBalance = 0
            self.history = TransactionHistory()
        }
        
        var publicAddress: PublicWalletAddress?
        var seed: Seed?
        var blockchainHeight: String
        var daemonBlockchainHeight: String
        var balance: UInt64
        var unlockedBalance: UInt64
        var history: TransactionHistory
    }
}














