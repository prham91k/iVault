//
//  ScanVC.swift
//  XWallet
//
//  Created by loj on 17.12.17.
//

import AVFoundation
import UIKit


public protocol ScanVCDelegate: AnyObject {
    func scanVCDelegateBackButtonTouched()
    func scanVCDelegateUriDetected(uri: String, viewController: ScanVC)
}


public class ScanVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationViewXFiller: UIView!
    
    @IBAction func backButtonTouched() {
        self.delegate?.scanVCDelegateBackButtonTouched()
    }
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    public weak var delegate: ScanVCDelegate?
    
    public var viewTitle: String?
    public var backButtonTitle: String?
    public var notSupportedTitle: String?
    public var notSupportedMessage: String?
    public var ok: String?

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateView()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession = nil
    }

    public func startScanning() {
        self.startCapturing()
        self.showNavigationBar()
    }

    private func setup() {
        self.view.backgroundColor = UIColor.black
        self.startCapturing()
        self.showNavigationBar()
    }
    
    private func showNavigationBar() {
        self.view.bringSubviewToFront(self.navigationView)
        self.view.bringSubviewToFront(self.navigationViewXFiller)
    }
    
    private func updateView() {
        if let viewTitle = self.viewTitle {
            self.titleLabel.text = viewTitle
        }
        if let backButtonTitle = self.backButtonTitle {
            self.backButton.setTitle(backButtonTitle, for: .normal)
        }
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func startCapturing() {
        self.captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (self.captureSession.canAddInput(videoInput)) {
            self.captureSession.addInput(videoInput)
        } else {
            self.failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (self.captureSession.canAddOutput(metadataOutput)) {
            self.captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            self.failed()
            return
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer.frame = view.layer.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        
        self.captureSession.startRunning()
    }

    private func failed() {
        let alert = UIAlertController(title: self.notSupportedTitle ?? "!!title",
                                      message: self.notSupportedMessage ?? "!!message",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.ok ?? "!!OK", style: .default, handler: { action in
            self.delegate?.scanVCDelegateBackButtonTouched()
        }))
        self.present(alert, animated: true)
        self.captureSession = nil
    }
}


extension ScanVC: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection)
    {
        self.captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.found(code: stringValue)
        }
    }
    
    func found(code: String) {
        print(code)
        self.delegate?.scanVCDelegateUriDetected(uri: code, viewController: self)
    }
}
