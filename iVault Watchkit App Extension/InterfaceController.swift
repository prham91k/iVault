//
//  InterfaceController.swift
//  XWallet Watchkit App Extension
//
//  Created by loj on 15.07.18.
//

import Foundation
import WatchKit


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var authenticateButton: WKInterfaceButton!
    @IBOutlet weak var qrcImage: WKInterfaceImage!

    @IBAction func authenticateButtonTouched() {
        if let requestId = self.requestId {
            self.communicationService.authenticate(requestId: requestId)
            self.requestId = nil
        }
        self.updateControls(authenticate: false)
    }

    private var communicationService: CommunicationServiceProtocol!
    private var requestId: String?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        print("*** watch: interfaceController.awake")

        self.communicationService = CommunicationServiceProvider.current()

        self.handle(context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("*** watch: interfaceController.willActivate")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("*** watch: interfaceController.didDeactivate")
    }

    private func updateControls(authenticate: Bool) {
        if authenticate {
            self.showAuthenticateButton()
        } else {
            self.showQRC()
        }
    }

    private func handle(_ context: Any?) {
        guard let dictionary = context as? [String:Any?] else {
            return
        }

        if let requestId = dictionary[ApplicationContextTag.requestId.rawValue] as? String {
            self.requestId = requestId
            let askForAuthentication = self.requestId != nil
            self.updateControls(authenticate: askForAuthentication)
        }

        if let qrcImage = dictionary[ApplicationContextTag.qrcImage.rawValue] as? UIImage {
            self.qrcImage.setImage(qrcImage)
        }
    }

    private func showQRC() {
        self.qrcImage.setHidden(false)

        self.label.setHidden(true)
        self.authenticateButton.setHidden(true)
    }

    private func showAuthenticateButton() {
        self.label.setHidden(false)
        self.authenticateButton.setHidden(false)

        self.qrcImage.setHidden(true)
    }
}
