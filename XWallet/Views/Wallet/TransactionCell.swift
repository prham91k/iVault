//
//  TransactionCell.swift
//  XWallet
//
//  Created by loj on 19.11.17.
//

import UIKit


public class TransactionCell: UITableViewCell {
    
    @IBOutlet weak var directionImageView: UIImageView!
    @IBOutlet weak var trxTimeLabel: UILabel!
    @IBOutlet weak var trxAmountLabel: UILabel!
    @IBOutlet weak var confirmationsStackView: UIStackView!
    @IBOutlet weak var confirmationsLabel: UILabel!
    
    public var direction: TransactionDirection?
    public var isPending: Bool?
    public var isFailed: Bool?
    public var trxAmount: String?
    public var confirmations: UInt64?
    public var trxTimestamp: String?
    public var localizer: Localizable?
    
    private let arrowReceived = "ReceivedTransactionIcon"
    private let arrowSent = "SentTransactionIcon"
    
    public func redraw() {
        self.showData()
    }
    
    private func showData() {
        guard let localizer = self.localizer else { return }

        var amountDescription = ""
        var isPendingDescription = ""
        var isFailedDescription = ""
        
        if let direction = self.direction {
            switch direction {
            case .received:
                self.directionImageView.image = UIImage(named: arrowReceived)!
            case .sent:
                self.directionImageView.image = UIImage(named: arrowSent)
            }
            amountDescription = " \(localizer.localized(direction))"
        }
        if let isPending = self.isPending {
            isPendingDescription = isPending ? " \(localizer.localized("trxState.pending"))" : ""
        }
        if let isFailed = self.isFailed {
            isFailedDescription = isFailed ? " \(localizer.localized("trxState.failed"))" : ""
        }
        if let trxAmount = self.trxAmount {
            self.trxAmountLabel.text = trxAmount
        }
        if let trxTimestamp = self.trxTimestamp {
            self.trxTimeLabel.text = trxTimestamp
        }
        
        self.trxAmountLabel.text?.append(amountDescription)
        self.trxAmountLabel.text?.append(isPendingDescription)
        self.trxAmountLabel.text?.append(isFailedDescription)
        
        self.showConfirmations()
    }
    
    private func showConfirmations() {
        guard let confirmations = self.confirmations,
            let localizer = self.localizer,
            let isPending = self.isPending,
            let isFailed = self.isFailed else
        {
            self.confirmationsStackView.isHidden = true
            return
        }
        
        if isFailed {
            self.confirmationsStackView.isHidden = true
            return
        }
        
        if isPending {
            self.confirmationsStackView.isHidden = true
            return
        }
        
        if confirmations >= Constants.numberOfRequiredConfirmations {
            self.confirmationsStackView.isHidden = true
            return
        }
        
        self.confirmationsStackView.isHidden = false
        self.confirmationsLabel.text = "\(localizer.localized("global.confirmations")): \(confirmations)"
    }
}
