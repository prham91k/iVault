//
//  LegalVC.swift
//  XWallet
//
//  Created by loj on 22.07.19.
//  Copyright © 2019 loj. All rights reserved.
//

import UIKit

public protocol LegalVCDelegate: class {
    func legalVCAcceptButtonTouched(viewController: LegalVC)
    func legalVCDeclineButtonTouched(viewController: LegalVC)
}

public class LegalVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var legalTextView: UITextView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!

    @IBAction func acceptButtonTouched() {
        self.delegate?.legalVCAcceptButtonTouched(viewController: self)
    }

    @IBAction func declineButtonTouched() {
        self.delegate?.legalVCDeclineButtonTouched(viewController: self)
    }

    public weak var delegate: LegalVCDelegate?

    public var viewTitle: String?
    public var acceptButtonTitle: String?
    public var declineButtonTitle: String?

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateView()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.legalTextView.setContentOffset(.zero, animated: false)
    }

    private func updateView() {
        if let viewTitle = self.viewTitle {
            self.titleLabel.text = viewTitle
        }

        if let acceptButtonTitle = self.acceptButtonTitle {
            self.acceptButton.setTitle(acceptButtonTitle, for: .normal)
        }

        if let declineButtonTitle = self.declineButtonTitle {
            self.declineButton.setTitle(declineButtonTitle, for: .normal)
        }

        self.setLegalText()
    }

    private func setLegalText() {
        self.legalTextView.text =
        """
        X Wallet Legal Disclaimer

        1.    Use of X Wallet
        The X Wallet app (hereinafter, referred to as the "App") allows the use of accessing the Monero Blockchain/network. You are not authorized, and nor should you rely on the App for legal advice, business advice, or advice of any kind. You act at your own risk in reliance on the contents of the App. Should you make a decision to act or not act you should contact a licensed attorney in the relevant jurisdiction in which you want or need help. In no way are the owners of, or contributors to, the App responsible for the actions, decisions, or other behavior taken or not taken by you in reliance upon the App.

        2.    Privacy
        The App does not use any analytics or collect your personal data. Checkout the source code on Gitlab.

        3.    Translations
        The App may contain translations of the English version of the content available on the App. These translations are provided only as a convenience. In the event of any conflict between the English language version and the translated version, the English language version shall take precedence. If you notice any inconsistency, please report them.

        4.    Risks related to the use of the App.
        The App and the App’s owner will not be responsible for any losses, damages or claims arising from events falling within the scope of the following categories:
              (1) Mistakes made by the user of any Monero related software or service, e.g., forgotten passwords, payments sent to wrong Monero addresses, and accidental deletion of wallets.
              (2) Software problems of the App and/or any Monero related software or service, e.g., corrupted wallet file, incorrectly constructed transactions, unsafe cryptographic libraries, malware affecting the App and/or any Monero related software or service.
              (3) Technical failures in the hardware of the user of any Monero related software or service, e.g., data loss due to a faulty or damaged storage device.
              (4) Security problems experienced by the user of any Monero related software or service, e.g., unauthorized access to users' wallets and/or accounts.
              (5) Actions or inactions of third parties and/or events experienced by third parties, e.g., bankruptcy of service providers, information security attacks on service providers, and fraud conducted by third parties.

        5.    Investment risks
        The investment in Monero can lead to loss of money over short or even long periods. The investors in Monero should expect prices to have large range fluctuations.

        6.    Compliance with tax obligations
        The users of the App are solely responsible to determinate what, if any, taxes apply to their Monero transactions. The owners of, or contributors to, the App are not responsible for determining the taxes that apply to Monero transactions.

        7.    The App does not store, send, or receive Moneros
        The App does not store, send or receive Monero. This is because Monero exists only by virtue of the ownership record maintained in the Monero network. Any transfer of title in Moneros occurs within a decentralized Monero network, and not on the App.

        8.    No warranties
        The App is provided on an "as is" basis without any warranties of any kind regarding the App and/or any content, data, materials and/or services provided on the App.

        9.    Limitation of liability
        Unless otherwise required by law, in no event shall the owners of, or contributors to, the App be liable for any damages of any kind, including, but not limited to, loss of use, loss of profits, or loss of data arising out of or in any way connected with the use of the App.

        10.    Arbitration
        The user of the App agrees to arbitrate any dispute arising from or in connection with the App or this disclaimer, except for disputes related to copyrights, logos, trademarks, trade names, trade secrets or patents.

        11.    Last amendment
        This disclaimer was amended for the last time on July 27, 2019
        """
    }
}
