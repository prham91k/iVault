//
//  ActivityIndicatorEnabled
//  XWallet
//
//  Created by loj on 11.08.18.
//

import UIKit


public protocol ActivityIndicatorEnabled {
    func showActivityIndicator()
    func hideActivityIndicator()
    var activityIndicator: ActivityIndicatorHUD? { get set }
}



extension ActivityIndicatorEnabled where Self: UIViewController {

    public func showActivityIndicator() {
        self.activityIndicator?.showAtCenter(ofParentView: self.view)
    }

    public func hideActivityIndicator() {
        self.activityIndicator?.hide()
    }
}
