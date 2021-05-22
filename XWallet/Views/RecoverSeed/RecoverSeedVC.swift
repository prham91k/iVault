//
//  RecoverSeedVC.swift
//  XWallet
//
//  Created by loj on 13.11.17.
//

import UIKit


protocol RecoverSeedVCDelegeta: class {
    func recoverSeedVCButtonNextTouched(seed: Seed)
    func recoverSeedVCButtonBackTouched()
}


class RecoverSeedVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var instructionTextLabel: UILabel!
    @IBOutlet weak var seedTextView: UITextView!
    
    @IBAction func nextButtonTouched() {
        guard let seed = Seed(sentence: self.seedTextView.text) else {
            // TODO: (loj) show popup that seed string is invalid
            return
        }
        self.delegate?.recoverSeedVCButtonNextTouched(seed: seed)
    }
    
    @IBAction func backButtonTouched() {
        self.delegate?.recoverSeedVCButtonBackTouched()
    }
    
    public weak var delegate: RecoverSeedVCDelegeta?
    
    public var subTitle: String?
    public var instructionText: String?
    public var backButtonTitle: String?
    public var nextButtonTitle: String?
    public var progress: Float = 1.0

    override func viewWillAppear(_ animated: Bool) {
        self.updateView()
        self.showKeyboard()
    }
    
    private func updateView() {
        if let subTitle = self.subTitle {
            self.subTitleLabel.text = subTitle
        }
        if let instructionText = self.instructionText {
            self.instructionTextLabel.text = instructionText
        }
        if let backButtonTitle = self.backButtonTitle {
            self.backButton.setTitle(backButtonTitle, for: .normal)
        }
        if let nextButtonTitle = self.nextButtonTitle {
            self.nextButton.setTitle(nextButtonTitle, for: .normal)
        }
        self.progressView.progress = self.progress
        self.seedTextView.text = ""
    }
    
    private func showKeyboard() {
        self.seedTextView.becomeFirstResponder()
    }
    
}
