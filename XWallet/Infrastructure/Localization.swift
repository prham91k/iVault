//
//  Localization.swift
//  XWallet
//
//  Created by loj on 03.03.19.
//  Copyright © 2019 loj. All rights reserved.
//

import Foundation


public protocol Localizable: AnyObject {
    func use(languageId: String)
    func localized(_ text: String) -> String
    func localized(_ age: FiatAge) -> String
    func localized(_ direction: TransactionDirection) -> String
    func localized(_ languages: [String:[LanguageId]]) -> DataSourceDictionary
}


public class Localization: Localizable {

    private var languageBundle: Bundle?

    public init(languageId: String) {
        self.use(languageId: languageId)
    }

    public func localized(_ text: String) -> String {
        return self.languageBundle?.localizedString(forKey: text, value: text, table: "InfoPlist")
            ?? text
    }

    public func use(languageId: String) {
        let path = Bundle.main.path(forResource: languageId, ofType: "lproj")!
        self.languageBundle = Bundle(path: path)!
    }
}


public extension Localization {

    static func initialLanguage() -> String {
        let preferredLanguages = Locale.preferredLanguages
        let supportedLanguages = LanguageId.allCases.map { $0.rawValue }

        for preferredLanguage in preferredLanguages {
            if supportedLanguages.contains(preferredLanguage) {
                return preferredLanguage
            }

            for supportedLanguage in supportedLanguages {
                if preferredLanguage.starts(with: supportedLanguage) {
                    return supportedLanguage
                }
            }
        }

        return Constants.defaultLanguage
    }
}


public extension Localization {

    func localized(_ age: FiatAge) -> String {
        switch age {
        case .never:
            return self.localized("age.never")
        case .recent:
            return self.localized("age.recent")
        case .moreThan10Minutes:
            return self.localized("age.moreThan10MinutesAgo")
        case .moreThan1Hour:
            return self.localized("age.moreThan1HourAgo")
        case .moreThan1Day:
            return self.localized("age.moreThan1DayAgo")
        }
    }
}


public extension Localization {

    func localized(_ direction: TransactionDirection) -> String {
        switch direction {
        case .received:
            return self.localized("transactionDirection.received")
        case .sent:
            return self.localized("transactionDirection.sent")
        }
    }
}


public extension Localization {

    func localized(_ languages: [String : [LanguageId]]) -> DataSourceDictionary {
        var result = DataSourceDictionary()

        for (key, value) in languages {
            result[key] = value.map {
                (value: self.localized("language.\($0.rawValue)"),
                    id: $0.rawValue)
            }
        }

        return result
    }
}
