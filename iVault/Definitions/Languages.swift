//
//  Languages.swift
//  XWallet
//
//  Created by loj on 29.06.18.
//

import Foundation


public enum LanguageId: String, CaseIterable {
    case en = "en"
    case de = "de"
//    case ru_RU = "ru-RU"
}


public extension Constants {

    static let languages =
        [
            "":LanguageId.allCases
    ]
}
