//
//  WalletVC.swift
//  XWallet
//
//  Created by loj on 16.11.17.
//

import UIKit


protocol WalletVCDelegate: AnyObject {
    func walletVCSettingsButtonTouched()
    func walletVCSendTouched()
    func walletVCReceiveTouched()
    func walletVCWillEnterForeground()
}


class WalletVC: UIViewController {
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var xmrAmountLabel: UILabel!
    @IBOutlet weak var otherAmountLabel: UILabel!
    @IBOutlet weak var configButton: UIButton!
    @IBOutlet weak var sendButtonView: UIView!
    @IBOutlet weak var sendButtonLabel: UILabel!
    @IBOutlet weak var sendButtonImageView: UIImageView!
    @IBOutlet weak var receiveButtonView: UIView!
    @IBOutlet weak var receiveButtonLabel: UILabel!
    @IBOutlet weak var receiveButtonImageView: UIImageView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var emptyTransactionsLabel: UILabel!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var unlockLabel: UILabel!
    // Container handler used for gesture recognizer
    @IBOutlet weak var sendButtonStackView: UIStackView!
    @IBOutlet weak var receiveButtonStackView: UIStackView!
    
    @IBAction func settingsButtonTouched() {
        self.delegate?.walletVCSettingsButtonTouched()
    }
    
    @objc func sendButtonTouched() {
        self.delegate?.walletVCSendTouched()
    }
    
    @objc func receiveButtonTouched() {
        self.delegate?.walletVCReceiveTouched()
    }
    
    public weak var delegate: WalletVCDelegate?
    public weak var localizer: Localizable?
    public var viewModel: WalletViewModel?
    
    private var sendButtonGestureRecognizer = UITapGestureRecognizer()
    private var receiveButtonGestureRecognizer = UITapGestureRecognizer()
    
    private var syncIsInProgress = false
    private var hasLockedBalance = false

    public func refresh() {
        self.updateControls()
    }
    
    public func viewModelIsUpdated() {
//        print("############# updating view due to updated viewmodel, triggered by listener")
        self.showData()
        
        self.hasLockedBalance = self.viewModel?.hasLockedBalance ?? false
        self.updateSendButtons()
    }

    public func walletSyncing(initialHeight: UInt64, walletHeight: UInt64, blockChainHeight: UInt64) {
        let min = Double(initialHeight)
        let max = Double(blockChainHeight)
        let current = Double(walletHeight)
        
        
        var percent = Int((current - min) / (max - min) * 100.0)
        if percent > 99 {
            percent = 99
        }
        if percent < 0 {
            percent = 0
        }
        
        if let viewTitleSyncing = self.viewModel?.viewTitleSyncing {
            self.viewTitleLabel.text = "\(viewTitleSyncing) \(percent)%"
        } else {
            self.viewTitleLabel.text = "\(percent)%"
        }
        
        self.progressView.setProgress(Float(percent) / 100.0, animated: true)
        self.progressView.isHidden = false
        self.heightLabel.text = "Height: \(String(format: "%.0f", current)) / \(String(format: "%.0f", max))"

        self.syncIsInProgress = true
        self.updateSendButtons()
    }
    
    public func walletSyncCompleted() {
        if let viewTitle = self.viewModel?.viewTitle {
            self.viewTitleLabel.text = viewTitle
        }


        self.syncIsInProgress = false
        self.updateSendButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
        self.disableSendButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateControls()
        self.disableSendButton()
        self.showData()

        self.willEnterForeground()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func willEnterForeground() {
        self.delegate?.walletVCWillEnterForeground()
    }
    
    private func setup() {
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        
        self.sendButtonGestureRecognizer.addTarget(self, action: #selector(self.sendButtonTouched))
        self.sendButtonView.addGestureRecognizer(self.sendButtonGestureRecognizer)
        
        self.receiveButtonGestureRecognizer.addTarget(self, action: #selector(self.receiveButtonTouched))
        self.receiveButtonView.addGestureRecognizer(self.receiveButtonGestureRecognizer)

//        self.tabBarView.layer.shadowColor = UIColor.lightGray.cgColor
//        self.tabBarView.layer.shadowOpacity = 0.7
//        self.tabBarView.layer.shadowOffset = .zero
//        self.tabBarView.layer.shadowRadius = 2
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    private func updateControls() {
        if let viewTitle = self.viewModel?.viewTitle {
            self.viewTitleLabel.text = viewTitle
        }
//        self.progressView.isHidden = true
        self.progressView.isHidden = false

        if let configButtonTitle = self.viewModel?.configButtonTitle {
            self.configButton.setTitle(configButtonTitle, for: .normal)
        }
        if let sendButtonTitle = self.viewModel?.sendButtonTitle {
            self.sendButtonLabel.text = sendButtonTitle
        }
        
        if let receiveButtonTitle = self.viewModel?.receiveButtonTitle {
            self.receiveButtonLabel.text = receiveButtonTitle
        }

        if let emptyTransactionsText = self.viewModel?.emptyTransactionsText {
            self.emptyTransactionsLabel.text = emptyTransactionsText
        }
    }
    
    private func showData() {
        guard let viewModel = self.viewModel else {
            self.showEmptyData()
            return
        }
        
        // Listener might fire before view is completly initialized
        guard let xmrAmountLabel = self.xmrAmountLabel,
            let otherAmountLabel = self.otherAmountLabel,
            let historyTableView = self.historyTableView else { return }

        if !viewModel.history.isEmpty {
            self.emptyTransactionsLabel.isHidden = true
        }
        
        xmrAmountLabel.text = viewModel.xmrAmount

        otherAmountLabel.text = "\(viewModel.otherCurrency) \(viewModel.otherAmount)"
        
        self.progressView.isHidden = true
        
        if(!syncIsInProgress) {
            self.progressView.setProgress(1, animated: true)
            let height = Double(self.viewModel?.blockChainHeight ?? 0)
            self.heightLabel.text =  String(format: "Height: %.0f",height);
        }
        
        self.unlockLabel.text = "Unlock : \(self.viewModel?.unlockBalance ?? "0.00") XLA"
        
        historyTableView.reloadData()
    }
    
    private func showEmptyData() {
        self.xmrAmountLabel.text = "---"
        self.otherAmountLabel.text = "---"
        self.emptyTransactionsLabel.isHidden = false
        self.historyTableView.reloadData()
    }
    
    private func updateSendButtons() {
        if self.hasLockedBalance || self.syncIsInProgress {
            self.disableSendButton()
        } else {
            self.enableSendButton()
        }
    }
    
    private func enableSendButton() {
        // Listener might fire before view is completly initialized
        guard let sendButtonView = self.sendButtonView else {
            return
        }
        sendButtonView.isUserInteractionEnabled = true
        sendButtonStackView.alpha = 1.0
    }
    
    private func disableSendButton() {
        // Listener might fire before view is completly initialized
        guard let sendButtonView = self.sendButtonView else {
            return
        }
        sendButtonView.isUserInteractionEnabled = false
        sendButtonStackView.alpha = 0.25
    }
}


extension WalletVC: UITableViewDelegate {
}


extension WalletVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else {
            return 0
        }
        
        return viewModel.history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.historyTableView.dequeueReusableCell(withIdentifier: "TrxCell") as! TransactionCell

        guard let viewModel = self.viewModel else {
            return cell
        }
        
        let cellData = viewModel.history[indexPath.row]
        cell.direction = cellData.direction
        cell.isPending = cellData.isPending
        cell.isFailed = cellData.isFailed
        cell.trxAmount = cellData.readableAmountWithNetworkFee()+" XLA"
        cell.confirmations = cellData.confirmations
        cell.trxTimestamp = cellData.readableTimestamp()
        cell.localizer = self.localizer
        cell.redraw()
        return cell
    }
}
