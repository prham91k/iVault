//
//  SettingsVC.swift
//  XWallet
//
//  Created by loj on 21.01.18.
//

import UIKit
import MessageUI


class SettingsVC: UIViewController {
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButtonTouched() {
        self.viewModel.delegate?.settingsVCBackButtonTouched()
    }
    
    public var viewModel: SettingsViewModel = SettingsViewModel()

    public func refresh() {
        self.updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateControls()
    }

    private func setup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func updateControls() {
        if let viewTitle = self.viewModel.viewTitle {
            self.viewTitleLabel.text = viewTitle
        }
        if let backButtonTitle = self.viewModel.backButtonTitle {
            self.backButton.setTitle(backButtonTitle, for: .normal)
        }
    }
    
    private func updateView() {
        self.updateControls()
        self.tableView.reloadData()
    }
    
    private enum CellIdentifier: String {
        case selectionCell = "SelectionCell"
        case actionCell = "ActionCell"
        case actionCellWithSubTitle = "ActionCellWithSubTitle"
        case warningCellWithSubTitle = "WarningCellWithSubTitle"
    }
    
    private var cellDefinitions: [Int:(cell:UITableViewCell, height:Int, action:(() -> Void)?)] {
        get {
            return [0: (fiatConversionUnitsCell, 104, self.viewModel.delegate?.settingsVCFiatConversionUnitsSelectionTouched),
                    1: (languageCell, 104, self.viewModel.delegate?.settingsVCLanguageSelectionTouched),
                    2: (displayRecoverySeedCell, 142, nil),
                    3: (changePinCell, 122, nil),
//                    4: (tfaSupportCell, 122, nil),
                    4: (selectNodeCell, 142, nil),
                    5: (feedbackCell, 122, nil),
                    6: (nukeXWalletCell, 142, nil),
                    7: (privacyCell, 122, nil)
           ]
        }
    }

    private var fiatConversionUnitsCell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.selectionCell.rawValue)
                as! SelectionCell
            if let cellTitle = self.viewModel.fiatConversionUnitsCellTitle {
                cell.cellTitle = cellTitle
            }
            if let selectedValue = self.viewModel.fiatConversionUnitsSelectedValue {
                cell.selectedValue = selectedValue
            }
            cell.buttonTouchedHandler = self.viewModel.delegate?.settingsVCFiatConversionUnitsSelectionTouched
            cell.redraw()
            return cell
        }
    }

    private var languageCell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.selectionCell.rawValue)
                as! SelectionCell
            if let cellTitle = self.viewModel.languageCellTitle {
                cell.cellTitle = cellTitle
            }
            if let selectedValue = self.viewModel.languageSelectedValue {
                cell.selectedValue = selectedValue
            }
            cell.buttonTouchedHandler = self.viewModel.delegate?.settingsVCLanguageSelectionTouched
            cell.redraw()
            return cell
        }
    }
    
    private var displayRecoverySeedCell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.actionCellWithSubTitle.rawValue)
                as! ActionCellWithSubTitle
            if let cellTitle = self.viewModel.displayRecoverySeedCellTitle {
                cell.cellTitle = cellTitle
            }
            if let subTitle = self.viewModel.displayRecoverySeedCellSubTitle {
                cell.cellSubTitle = subTitle
            }
            if let buttonTitle = self.viewModel.displayRecoverySeedCellButtonTitle {
                cell.buttonTitle = buttonTitle
            }
            cell.buttonTouchedHandler = self.viewModel.delegate?.settingsVCRevealRecoverySeedButtonTouched
            cell.redraw()
            return cell
        }
    }
    
    private var changePinCell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.actionCell.rawValue)
                as! ActionCell
            if let cellTitle = self.viewModel.resetPinCellTitle {
                cell.cellTitle = cellTitle
            }
            if let buttonTitle = self.viewModel.resetPinCellButtonTitle {
                cell.buttonTitle = buttonTitle
            }
            cell.buttonTouchedHandler = self.viewModel.delegate?.settingsVCChangePinButtonTouched
            cell.redraw()
            return cell
        }
    }

    private var tfaSupportCell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.actionCell.rawValue)
                as! ActionCell
            if let cellTitle = self.viewModel.tfaSupportCellTitle {
                cell.cellTitle = cellTitle
            }
            if let buttonTitle = self.viewModel.tfaSupportButtonTitle {
                cell.buttonTitle = buttonTitle
            }
            cell.buttonTouchedHandler = self.viewModel.delegate?.settingsVC2FASupportButtonTouched
            cell.redraw()
            return cell
        }
    }

    private var selectNodeCell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.actionCellWithSubTitle.rawValue)
                as! ActionCellWithSubTitle
            if let cellTitle = self.viewModel.selectNodeCellTitle {
                cell.cellTitle = cellTitle
            }
            if let subTitle = self.viewModel.selectNodeCellSubTitle {
                cell.cellSubTitle = subTitle
            }
            if let buttonTitle = self.viewModel.selectNodeCellButtonTitle {
                cell.buttonTitle = buttonTitle
            }
            cell.buttonTouchedHandler = self.viewModel.delegate?.settingsVCSelectNodeButtonTouched
            cell.redraw()
            return cell
        }
    }
    
    private var nukeXWalletCell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.warningCellWithSubTitle.rawValue)
                as! WarningCellWithSubTitle
            if let cellTitle = self.viewModel.nukeXWalletCellTitle {
                cell.cellTitle = cellTitle
            }
            if let subTitle = self.viewModel.nukeXWalletCellSubTitle {
                cell.cellSubTitle = subTitle
            }
            if let buttonTitle = self.viewModel.nukeXWalletCellButtonTitle {
                cell.buttonTitle = buttonTitle
            }
            cell.buttonTouchedHandler = self.viewModel.delegate?.settingsVCNukeXWalletButtonTouched
            cell.redraw()
            return cell
        }
    }

    private var feedbackCell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.actionCell.rawValue) as! ActionCell
            if let cellTitle = self.viewModel.feedbackCellTitle {
                cell.cellTitle = cellTitle
            }
            if let buttonTitle = self.viewModel.feedbackCellButtonTitle {
                cell.buttonTitle = buttonTitle
            }
            cell.buttonTouchedHandler = { () in self.askForFeedback() }
            cell.redraw()
            return cell
        }
    }

    private var privacyCell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.actionCell.rawValue) as! ActionCell
            if let cellTitle = self.viewModel.privacyCellTitle {
                cell.cellTitle = cellTitle
            }
            if let buttonTitle = self.viewModel.privacyCellButtonTitle {
                cell.buttonTitle = buttonTitle
            }
            cell.buttonTouchedHandler = { () in self.openPrivacyStatement() }
            cell.redraw()
            return cell
        }
    }

    private func openPrivacyStatement() {
        if let url = URL(string: Constants.privacyStatementLink) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}


extension SettingsVC: MFMailComposeViewControllerDelegate {

    private func askForFeedback() {
        let alertView = UIAlertController(title: self.viewModel.feedbackCellTitle,
                                          message: self.viewModel.feedbackDescription,
                                          preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: self.viewModel.feedbackShowFAQTitle,
                                          style: .default,
                                          handler: { (_) in self.showFAQ() }))
        alertView.addAction(UIAlertAction(title: self.viewModel.feedbackSendTitle,
                                          style: .default,
                                          handler: { (_) in self.sendFeedback() }))
        alertView.addAction(UIAlertAction(title: self.viewModel.feedbackCancelTitle,
                                          style: .default,
                                          handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }

    private func showFAQ() {
        if let url = URL(string: Constants.troubleShootingLink) {
            UIApplication.shared.open(url, options: [:])
        }
    }

    private func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Constants.feedbackEmail])
            mail.setSubject(self.viewModel.feedbackSubject ?? "")
            mail.setMessageBody(self.viewModel.feedbackMessageBody ?? "", isHTML: false)

            self.present(mail, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(
                title: self.viewModel.emailFailedTitle ?? "!!title",
                message: self.viewModel.emailFailedMessage ?? "!!message", 
                preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: self.viewModel.ok ?? "!!OK",
                                          style: UIAlertAction.Style.cancel,
                                          handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
}


extension SettingsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let actionOnSelection = self.cellDefinitions[indexPath.row]?.action {
            actionOnSelection()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellDefinition = self.cellDefinitions[indexPath.row]
        let height = cellDefinition?.height
        return CGFloat(height!)
    }
}


extension SettingsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellDefinitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDefinition = self.cellDefinitions[indexPath.row]
        let cell = cellDefinition?.cell
        return cell!
    }
}
