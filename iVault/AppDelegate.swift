//
//  AppDelegate.swift
//  XWallet
//
//  Created by loj on 26.07.17.
//

import UIKit
import WatchConnectivity


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

//    //TODO TEST code
//    lazy var notificationCenter: NotificationCenter = {
//        return NotificationCenter.default
//    }()

    var window: UIWindow?
    var appCoordinator: AppCoordinator!
    
    var moneroBag: MoneroBagProtocol!
    var walletLifecycle: WalletLifecycleServiceProtocol!
    var propertyStore: PropertyStoreProtocol!
    var secureStore: SecureStoreProtocol!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return false
        }

        self.setupWatchConnectivity()
//        self.setupNotificationCenter()

        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.tintColor = UIColor.black
        self.window?.rootViewController = navigationController
        
        self.moneroBag = IocContainer.instance.moneroBag
        self.walletLifecycle = IocContainer.instance.walletLifecycleService
        self.propertyStore = IocContainer.propertyStore
        self.secureStore = IocContainer.secureStore
        self.appCoordinator = AppCoordinator(navigationController: navigationController,
                                             moneroBag: self.moneroBag,
                                             onboardingService: IocContainer.instance.onboardingService,
                                             propertyStore: propertyStore,
                                             secureStore: secureStore,
                                             fileHandling: IocContainer.fileHandling,
                                             walletLifecycleService: IocContainer.instance.walletLifecycleService,
                                             fiatService: IocContainer.instance.fiatService,
                                             feeService: IocContainer.instance.feeService,
                                             moneroUriParser: IocContainer.instance.moneroUriParser,
                                             twoFactorAuthenticationService: IocContainer.instance.twoFactorAuthenticationService,
                                             localizer: IocContainer.localizer)
        self.appCoordinator.start()

        self.window?.makeKeyAndVisible()

        return true
    }


//    private func setupNotificationCenter() {
//        notificationCenter.addObserver(forName: NSNotification.Name(rawValue: "2FA"),
//                                       object: nil,
//                                       queue: nil)
//        { (notification:Notification) -> Void in
//            self.sendToWatch()
//        }
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if let wallet = self.moneroBag.wallet {
            self.walletLifecycle.lock(wallet: wallet)
            self.moneroBag.wallet = nil
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if self.propertyStore.onboardingIsFinished {
            //@@TODO "ask for app pin to unlock app"

            guard let walletPassword = secureStore.walletPassword else {
                //@@TODO "error: no wallet password found"
                return
            }
            
            self.moneroBag.wallet = self.walletLifecycle.unlockWallet(withPassword: walletPassword)
            
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


extension AppDelegate: WCSessionDelegate {

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("*** phone: WC Session did become inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("*** phone: WC Session did deactivate")
        WCSession.default.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("*** phone: WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        print("*** phone: WC Session activated with state: \(activationState.rawValue)")
    }

    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

//    private func sendToWatch() {
//        let requestId = UUID().uuidString
//        if WCSession.isSupported() {
//            let message = ["requestId":"\(requestId)"]
//            let session = WCSession.default
//            if session.isWatchAppInstalled {
//                do {
//                    print("*** phone: sending to watch: \(message)")
//                    try session.updateApplicationContext(message)
//                } catch {
//                    print("*** phone: send failed with error: \(error)")
//                }
//            }
//        }
//    }


    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("*** phone: received application context: \(applicationContext)")

        if let requestId = applicationContext[ApplicationContextTag.requestId.rawValue] as? String {
            print("*** phone: receive requestId: \(requestId)")
        }
    }
}
