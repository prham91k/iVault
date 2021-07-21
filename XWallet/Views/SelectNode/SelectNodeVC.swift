//
//  ChooseNodeVC.swift
//  XWallet
//
//  Created by loj on 02.02.18.
//

import UIKit


protocol SelectNodeVCDelegate: AnyObject {
    func selectNodeVCBackButtonTouched()
    func selectNodeVCRestoreDefaultsButtonTouched(selectNodeVC: SelectNodeVC)
    func selectNodeVCConnectButtonTouched(address: String, userId: String, password: String, selectNodeVC: SelectNodeVC)
}


class SelectNodeVC: UIViewController {
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var defaultsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint!
    
    @IBAction func backButtonTouched() {
        self.tableView.endEditing(true)
        self.delegate?.selectNodeVCBackButtonTouched()
    }
    
    @IBAction func defaultsButtonTouched() {
        self.delegate?.selectNodeVCRestoreDefaultsButtonTouched(selectNodeVC: self)
    }
    
    public weak var delegate: SelectNodeVCDelegate?
    
    public var viewTitle: String?
    public var backButtonTitle: String?
    public var defaultsButtonTitle: String?
    public var addressLabelTitle: String?
    public var userIdLabelTitle: String?
    public var passwordLabelTitle: String?
    public var connectButtonTitle: String?
    
    public var address: String = ""
    public var userId: String = ""
    public var password: String = ""
    
    fileprivate let activityIndicator = ActivityIndicatorHUD()
    
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
        self.registerNotificationHandlers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.deregisterNotificationHandlers()
    }
    
    public func showActivityIndicator() {
        self.activityIndicator.showAtCenter(ofParentView: self.view)
    }
    
    public func hideActivityIndicator() {
        self.activityIndicator.hide()
    }

    private func setup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func registerNotificationHandlers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func deregisterNotificationHandlers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateControls() {
        if let viewTitle = self.viewTitle {
            self.viewTitleLabel.text = viewTitle
        }
        if let backButtonTitle = self.backButtonTitle {
            self.backButton.setTitle(backButtonTitle, for: .normal)
        }
        if let defaultsButtonTitle = self.defaultsButtonTitle {
            self.defaultsButton.setTitle(defaultsButtonTitle, for: .normal)
        }
    }
    
    private func updateView() {
        self.tableView.reloadData()
    }
    
    private enum CellIdentifier: String {
        case textFieldWithLabelCell = "TextFieldWithLabelCell"
        case actionCellWithoutTitleCell = "ActionCellWithoutTitleCell"
    }
    
    private var cellDefinitions: [Int:UITableViewCell] {
        get {
            return [0: addressCell,
                    1: userIdCell,
                    2: passwordCell,
                    3: connectCell]
        }
    }

    private var addressCell: UITableViewCell {
        get {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.textFieldWithLabelCell.rawValue) as! TextFieldCellWithLabel
            cell.textValue = self.address
            cell.descriptionValue = self.addressLabelTitle
            cell.onClose = { self.address = cell.textValue ?? "" }
            cell.redraw()
            return cell
        }
    }
    
    private var userIdCell: UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.textFieldWithLabelCell.rawValue) as! TextFieldCellWithLabel
        cell.textValue = self.userId
        cell.textValueIsPassword = false
        cell.descriptionValue = self.userIdLabelTitle
        cell.onClose = { self.userId = cell.textValue ?? "" }
        cell.redraw()
        return cell
    }
    
    private var passwordCell: UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.textFieldWithLabelCell.rawValue) as! TextFieldCellWithLabel
        cell.textValue = self.password
        cell.textValueIsPassword = true
        cell.descriptionValue = self.passwordLabelTitle
        cell.onClose = { self.password = cell.textValue ?? "" }
        cell.redraw()
        return cell
    }
    
    private var connectCell: UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier.actionCellWithoutTitleCell.rawValue) as! ActionCellWithoutTitle
        cell.buttonTitle = self.connectButtonTitle
        cell.buttonTouchedHandler = {
            self.tableView.endEditing(true)
            self.delegate?.selectNodeVCConnectButtonTouched(address: self.address,
                                                            userId: self.userId,
                                                            password: self.password,
                                                            selectNodeVC: self)
        }
        cell.redraw()
        return cell
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.height

        UIView.animate(withDuration: 0.1) {
            self.tableViewBottomLayoutConstraint.constant = keyboardHeight
            self.tableView.frame.size.height -= keyboardHeight
            self.tableView.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        UIView.animate(withDuration: 0.1) {
            self.tableViewBottomLayoutConstraint.constant = 0
            self.tableView.frame.size.height += keyboardHeight
            self.tableView.layoutIfNeeded()
        }
    }
}


extension SelectNodeVC: UITableViewDelegate {
    
}


extension SelectNodeVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellDefinitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cellDefinitions[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
