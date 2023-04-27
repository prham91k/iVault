//
//  SettingsViewModel.swift
//  XWallet
//
//  Created by loj on 19.08.18.
//

import Foundation
import UIKit


protocol SettingsVCProtocol: AnyObject {
    func settingsVCBackButtonTouched()
    func settingsVCFiatConversionUnitsSelectionTouched()
    func settingsVCLanguageSelectionTouched()
    func settingsVCRevealRecoverySeedButtonTouched()
    func settingsVCChangePinButtonTouched()
    func settingsVC2FASupportButtonTouched()
    func settingsVCSelectNodeButtonTouched()
    func settingsVCNukeXWalletButtonTouched()
    func settingsVCRescanWalletButtonTouched()
    func settingsVCMaxTrxHistoryButtonTouched()
}


struct SettingsViewModel {
    public var viewTitle: String?
    public var backButtonTitle: String?

    public var fiatConversionUnitsCellTitle: String?
    public var fiatConversionUnitsSelectedValue: String?
    public var languageCellTitle: String?
    public var languageSelectedValue: String?
    public var displayRecoverySeedCellTitle: String?
    public var displayRecoverySeedCellSubTitle: String?
    public var displayRecoverySeedCellButtonTitle: String?
    public var resetPinCellTitle: String?
    public var resetPinCellButtonTitle: String?
    public var tfaSupportCellTitle: String?
    public var tfaSupportButtonTitle: String?
    public var selectNodeCellTitle: String?
    public var selectNodeCellSubTitle: String?
    public var selectNodeCellButtonTitle: String?
    public var nukeXWalletCellTitle: String?
    public var nukeXWalletCellSubTitle: String?
    public var nukeXWalletCellButtonTitle: String?
    public var feedbackCellTitle: String?
    public var feedbackCellButtonTitle: String?
    public var feedbackSubject: String?
    public var feedbackMessageBody: String?
    public var feedbackDescription: String?
    public var feedbackShowFAQTitle: String?
    public var feedbackSendTitle: String?
    public var feedbackCancelTitle: String?
    public var privacyCellTitle: String?
    public var privacyCellButtonTitle: String?
    public var emailFailedTitle: String?
    public var emailFailedMessage: String?
    public var ok: String?
    public var rescanWalletCellTitle: String?
    public var rescanWalletCellSubTitle: String?
    public var rescanWalletCellButtonTitle: String?
    public var maxTrxHistoryCellTitle: String?
    public var maxTrxHistoryCellInput: String?
    public var maxTrxHistoryCellButtonTitle: String?
    
    public weak var delegate: SettingsVCProtocol?
}
