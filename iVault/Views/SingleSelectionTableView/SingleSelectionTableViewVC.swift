//
//  SingleSelectionTableViewVC.swift
//  XWallet
//
//  Created by loj on 22.01.18.
//

import UIKit

protocol SingleSelectionTableViewVCProtocol: AnyObject {
    func singleSelectionTableViewVCBackButtonTouched()
}


class SingleSelectionTableViewVC: UIViewController {
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButtonTouched() {
        self.delegate?.singleSelectionTableViewVCBackButtonTouched()
    }
    
    public weak var delegate: SingleSelectionTableViewVCProtocol?
    
    public var viewTitle: String?
    public var backButtonTitle: String?
    public var cellValues: TableViewDataSourceProtocol?
    public var currentId: String?
    
    public var selectionChangedAction: (() -> Void)?
    
    private let cellIdentifier = "SingleSelectionCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateControls()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.scrollToSelected()
    }

    private func setup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func updateControls() {
        if let viewTitle = self.viewTitle {
            self.viewTitleLabel.text = viewTitle
        }
        if let backButtonTitle = self.backButtonTitle {
            self.backButton.setTitle(backButtonTitle, for: .normal)
        }
        
        self.tableView.reloadData()
    }

    private func scrollToSelected() {
        guard let selectedId = self.currentId else { return }
        guard let cellValues = self.cellValues else { return }
        
        guard let indexPath = cellValues.indexPath(forId: selectedId) else {
            return
        }
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}


extension SingleSelectionTableViewVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SingleSelectionCell
        self.currentId = cell.id

        self.selectionChangedAction?()
        tableView.reloadData()
    }
}


extension SingleSelectionTableViewVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.cellValues?.sectionTitles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cellValues = self.cellValues else {
            return 0
        }
        return cellValues.numberOfRows(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SingleSelectionCell

        guard let cellValues = self.cellValues else {
            return cell
        }
        guard let cellValue = cellValues.value(atRow: indexPath.row, inSection: indexPath.section) else {
            return cell
        }
        
        cell.value = cellValue.value
        cell.id = cellValue.id
        
        if cellValue.id == self.currentId {
            cell.checkmarkIsSet = true
        } else {
            cell.checkmarkIsSet = false
        }

        cell.redraw()
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let cellValues = self.cellValues else {
            return ""
        }

        let sortedKeys = cellValues.sectionTitles.sorted { $0 < $1 }
        let key = sortedKeys[section]
        return key
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard let cellValues = self.cellValues else {
            return nil
        }
        let sortedKeys = cellValues.sectionTitles.sorted { $0 < $1 }
        return sortedKeys
    }
}
