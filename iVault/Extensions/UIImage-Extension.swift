//
//  UIImage-Extension.swift
//  XWallet
//
//  Created by loj on 31.08.18.
//

import Foundation
import UIKit


extension UIImage {

    func toData() -> Data? {
        if let data = self.pngData() {
            return data
        }
        if let data = self.jpegData(compressionQuality: 1.0) {
            return data
        }
        return nil
    }
}
