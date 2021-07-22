//
//  Configure2FAVC.swift
//  XWallet
//
//  Created by loj on 12.08.18.
//

import UIKit


class Configure2FAVC: UIViewController {

    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    @IBAction func backButtonTouched() {
        self.viewModel.delegate?.configure2FAVCBackButtonTouched()
    }

    public var viewModel = Configure2FAViewModel()

    public func refresh() {
        self.updateView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        case enable2FACell = "Enable2FACell"
    }

    private var cellDefinitions: [Int:(UITableViewCell, Int, ((UIViewController) -> Void)?)] {
        get {
            return [0: (enableAppleWatch2FACell, 212, self.viewModel.delegate?.configure2FAVCEnableAppleWatchTouched)
            ]
        }
    }

    private var enableAppleWatch2FACell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.enable2FACell.rawValue)
                as! Enable2FACell
            if let cellTitle = self.viewModel.enableAppleWatch2FACellTitle {
                cell.cellTitle = cellTitle
            }
            if let buttonTitle = self.viewModel.enableAppleWatch2FACellButtonTitle {
                cell.buttonTitle = buttonTitle
            }
            self.set(color: self.viewModel.enableAppleWatch2FACellButtonColor, on: cell.button)
            if let instructionText = self.viewModel.enableAppleWatch2FAInstructionText {
                cell.instructionText = instructionText
            }
            cell.buttonTouchedHandler = self.enableAppleWatch2FACellTouched
            cell.redraw()
            return cell
        }
    }
    
    private func enableAppleWatch2FACellTouched() {
        self.viewModel.delegate?.configure2FAVCEnableAppleWatchTouched(viewController: self)
    }

    private func set(color: ButtonColor, on button: UIButton) {
        button.backgroundColor = color.background.color
        button.alpha = color.background.alpha
        button.setTitleColor(color.text.color, for: .normal)
    }
}


extension Configure2FAVC: UITableViewDelegate {
    // has currently no actions on rows
}


extension Configure2FAVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellDefinitions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDefinition = self.cellDefinitions[indexPath.row]
        let cell = cellDefinition?.0
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellDefinition = self.cellDefinitions[indexPath.row]
        let height = cellDefinition?.1
        return CGFloat(height!)
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
