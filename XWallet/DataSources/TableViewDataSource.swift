//
//  TableViewDataSource
//  XWallet
//
//  Created by Loj on 01.07.18.
//

import Foundation


public typealias DataSourceValue = (value:String, id:String)
public typealias DataSourceDictionary = [String:[DataSourceValue]]


public protocol TableViewDataSourceProtocol {
    func numberOfSections() -> Int
    func numberOfRows(forSection section: Int) -> Int
    
    var sectionTitles: [String] { get }
    func value(atRow row: Int, inSection section: Int) -> DataSourceValue?

    func indexPath(forId id: String) -> IndexPath?
}


public class TableViewDataSource: TableViewDataSourceProtocol {
    
    private let dataSource: DataSourceDictionary
    
    public init(dictionary: DataSourceDictionary) {
        self.dataSource = dictionary
    }

    public init(dictionary: [String:[String]]) {
        var dataSource = DataSourceDictionary()
        for (key,value) in dictionary {
            dataSource[key] = value.map {
                (value:$0, id:$0)
            }
        }
        self.dataSource = dataSource
    }
    
    public func numberOfSections() -> Int {
        return self.sectionTitles.count
    }
    
    public func numberOfRows(forSection section: Int) -> Int {
        let key = self.sectionTitles[section]
        let values = self.dataSource[key] ?? [DataSourceValue]()
        return values.count
    }
    
    public lazy var sectionTitles: [String] = {
        return self.dataSource
            .keys
            .sorted { $0 < $1 }
    }()

    public func value(atRow row: Int, inSection section: Int) -> DataSourceValue? {
        let key = self.sectionTitles[section]
        guard let values = self.dataSource[key] else { return nil }
        let value = values[row]
        return value
    }

    public func indexPath(forId id: String) -> IndexPath? {
        guard let key = self.firstKey(forId: id) else { return nil }
        guard let section = self.sectionTitles.firstIndex(of: key) else { return nil }

        guard let values = self.dataSource[key] else { return nil }
        guard let row = values.map({ $0.id }).firstIndex(of: id) else { return nil }

        return IndexPath(row: row, section: section)
    }

    private func firstKey(forId id: String) -> String? {
        return self.dataSource
            .filter { $1.contains(where: { (_value: String, _id: String) -> Bool in return _id == id }) }
            .map { $0.0 }
            .first
    }
}
