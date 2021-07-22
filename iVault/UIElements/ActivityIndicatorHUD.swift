//
//  ActivityIndicatorHUD.swift
//  XWallet
//
//  Created by loj on 29.12.17.
//

import Foundation
import UIKit


public protocol ActivityIndicatorHUDProtocol {
    func showAtCenter(ofParentView parentView: UIView)
    func hide()
}


public class ActivityIndicatorHUD: ActivityIndicatorHUDProtocol {
    
    private var view: UIView?
    
    private let width: CGFloat = 120.0
    private let height: CGFloat = 120.0
    private let cornerRadius: CGFloat = 9.0

    public func showAtCenter(ofParentView parentView: UIView) {
        let x = (parentView.frame.width - self.width) / 2.0
        let y = (parentView.frame.height - self.height) / 2.0
        
        self.view = UIView(frame: CGRect(x: x, y: y, width: self.width, height: self.height))
        guard let view = self.view else { return }

        view.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        view.layer.cornerRadius = self.cornerRadius
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.layer.cornerRadius = self.cornerRadius
        blurView.clipsToBounds = true
        view.insertSubview(blurView, at: 0)
        
        parentView.addSubview(view)
        
        self.addActivityIndicator()
    }
    
    public func hide() {
        self.view?.removeFromSuperview()
    }
    
    private func addActivityIndicator() {
        let x = self.width / 4.0
        let y = self.height / 4.0
        let w = self.width / 2.0
        let h = self.height / 2.0
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: x, y: y, width: w, height: h))
        activityIndicator.style = .large
        activityIndicator.color = UIColor.darkGray
        activityIndicator.startAnimating()
        
        self.view?.addSubview(activityIndicator)
    }
}
