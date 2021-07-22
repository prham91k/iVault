//
//  QRCScannerTest.swift
//  XWalletTests
//
//  Created by loj on 10.06.18.
//

import XCTest
import iVault


class MoneroUriParserTest: XCTestCase {

    private var testee: MoneroUriParser!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        self.testee = MoneroUriParser()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    public func test_ValidateWalletAddressWithoutPrefix() {
        let uriWithoutPrefix = self.generateFullUri(withPrefix: false,
                                                    walletAddress: validWalletAddress,
                                                    paymentId: nil, amount: nil, description: nil)
        let result = self.testee.process(uriWithoutPrefix)
//        XCTAssertEqual(.ok, result.parseResult)
        XCTAssertEqual(validWalletAddress, result.payment.walletAddress)
    }
    
    public func test_ValidateWalletAddressWithPrefix() {
        let uriWithoutPrefix = self.generateFullUri(withPrefix: true,
                                                    walletAddress: validWalletAddress,
                                                    paymentId: nil, amount: nil, description: nil)
        let result = self.testee.process(uriWithoutPrefix)
//        XCTAssertEqual(.ok, result.parseResult)
        XCTAssertEqual(validWalletAddress, result.payment.walletAddress)
    }

    public func test_ValidateWalletAddressFormat() {
        let uriWithoutPrefix = self.generateFullUri(withPrefix: true,
                                                    walletAddress: invalidWalletAddress,
                                                    paymentId: nil, amount: nil, description: nil)
        let result = self.testee.process(uriWithoutPrefix)
//        XCTAssertEqual(.invalidWalletAddress, result.parseResult)
        XCTAssertNil(result.payment.walletAddress)
    }

    public func test_ValidatePaymentID() {
        let uriWithValidPaymentId = self.generateFullUri(withPrefix: true,
                                                         walletAddress: validWalletAddress,
                                                         paymentId: validPaymentId,
                                                         amount: validAmount,
                                                         description: validDescription)
        let resultForValidPaymentId = self.testee.process(uriWithValidPaymentId)
//        XCTAssertEqual(.ok, resultForValidPaymentId.parseResult)
        XCTAssertEqual(validPaymentId, resultForValidPaymentId.payment.paymentId)

        let uriWithInvalidPaymentId = self.generateFullUri(withPrefix: true,
                                                           walletAddress: validWalletAddress,
                                                           paymentId: invalidPaymentId,
                                                           amount: validAmount,
                                                           description: validDescription)
        let resultForInvalidPaymentId = self.testee.process(uriWithInvalidPaymentId)
//        XCTAssertEqual(.invalidPaymentId, resultForInvalidPaymentId.parseResult)
        XCTAssertNil(resultForInvalidPaymentId.payment.paymentId)
    }

    public func test_ValidateAmount() {

    }


    private func generateFullUri(withPrefix: Bool,
                                 walletAddress: String,
                                 paymentId: String?,
                                 amount: String?,
                                 description: String?) -> String
    {
        var parameters = [String]()

        var addressPart = ""
        if withPrefix {
            addressPart = "monero:\(walletAddress)"
        } else {
            addressPart = walletAddress
        }

        if let paymentId = paymentId {
            parameters.append("tx_payment_id=\(paymentId)")
        }

        if let amount = amount {
            parameters.append("tx_amount=\(amount)")
        }

        if let description = description {
            parameters.append("tx_description=\(description)")
        }

        return "\(addressPart)?\(parameters.joined(separator: "&"))"
    }


    private let validWalletAddress = "45J9JcnvugpQNQ34PyxtNANrtAkBe18rvd7kKPs7UsGqVmUGsgh5P1HX17D17d6Yyf8XRW9imLabq486M9264gA1PZd4G7f"
    private let validPaymentId = "657c5df1563fd943"
    private let validAmount = "22.08"
    private let validDescription = "validdescription"

    private let invalidWalletAddress = "45J9JcnvugpQNQ34PyxtNANrtAkBe18rvd7kKPs7UsGqVmUGsgh5P1HX17D17d6Yyf8XRW9imLabq486M9264gA"
    private let invalidPaymentId = "657c5df1563fd943X"
    private let invalidAmount = "22.08.2018"

}
