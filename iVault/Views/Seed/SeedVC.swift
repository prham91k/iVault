//
//  SeedVCViewController.swift
//  XWallet
//
//  Created by loj on 15.10.17.
//

import UIKit


protocol SeedVCDelegeta: AnyObject {
    func seedVCButtonNextTouched()
    func seedVCButtonBackTouched()
}


class SeedVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var instructionTextLabel: UILabel!
    
    @IBOutlet weak var word00: UILabel!
    @IBOutlet weak var word01: UILabel!
    @IBOutlet weak var word02: UILabel!
    @IBOutlet weak var word03: UILabel!
    @IBOutlet weak var word04: UILabel!
    @IBOutlet weak var word05: UILabel!
    @IBOutlet weak var word06: UILabel!
    @IBOutlet weak var word07: UILabel!
    @IBOutlet weak var word08: UILabel!
    @IBOutlet weak var word09: UILabel!
    @IBOutlet weak var word10: UILabel!
    @IBOutlet weak var word11: UILabel!
    @IBOutlet weak var word12: UILabel!
    @IBOutlet weak var word13: UILabel!
    @IBOutlet weak var word14: UILabel!
    @IBOutlet weak var word15: UILabel!
    @IBOutlet weak var word16: UILabel!
    @IBOutlet weak var word17: UILabel!
    @IBOutlet weak var word18: UILabel!
    @IBOutlet weak var word19: UILabel!
    @IBOutlet weak var word20: UILabel!
    @IBOutlet weak var word21: UILabel!
    @IBOutlet weak var word22: UILabel!
    @IBOutlet weak var word23: UILabel!
    @IBOutlet weak var word24: UILabel!
    
    @IBAction func nextButtonTouched() {
        self.delegate?.seedVCButtonNextTouched()
    }
    
    @IBAction func backButtonTouched() {
        self.delegate?.seedVCButtonBackTouched()
    }
    
    public weak var delegate: SeedVCDelegeta?
    
    public var viewTitle: String?
    public var subTitle: String?
    public var instructionText: String?
    public var backButtonTitle: String?
    public var nextButtonTitle: String?
    public var progress: Float?
    
    public var seed: Seed?

    override func viewWillAppear(_ animated: Bool) {
        self.updateView()
    }
    
    private func updateView() {
        if let viewTitle = self.viewTitle {
            self.viewTitleLabel.text = viewTitle
        }
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
        if let progress = self.progress {
            self.progressView.progress = progress
            self.progressView.isHidden = false
        } else {
            self.progressView.isHidden = true
        }
        
        self.showSeed()
    }
    
    private func showSeed() {
        guard let seed = self.seed else {
            return
        }
        
        let words = seed.words
        
        self.word00.text = words[0]
        self.word01.text = words[1]
        self.word02.text = words[2]
        self.word03.text = words[3]
        self.word04.text = words[4]
        self.word05.text = words[5]
        self.word06.text = words[6]
        self.word07.text = words[7]
        self.word08.text = words[8]
        self.word09.text = words[9]
        self.word10.text = words[10]
        self.word11.text = words[11]
        self.word12.text = words[12]
        self.word13.text = words[13]
        self.word14.text = words[14]
        self.word15.text = words[15]
        self.word16.text = words[16]
        self.word17.text = words[17]
        self.word18.text = words[18]
        self.word19.text = words[19]
        self.word20.text = words[20]
        self.word21.text = words[21]
        self.word22.text = words[22]
        self.word23.text = words[23]
        self.word24.text = words[24]
    }

}
