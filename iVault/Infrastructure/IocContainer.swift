//
//  IocContainer.swift
//  XWallet
//
//  Created by loj on 06.08.17.
//

import Foundation


public protocol IocContainerProtocol {
    
    static var propertyStore: PropertyStoreProtocol { get }
    static var secureStore: SecureStoreProtocol { get }
    static var fileHandling: FileHandlingProtocol { get }
    static var localizer: Localizable { get }
    
    var moneroBag: MoneroBagProtocol { get }
    var onboardingService: OnboardingServiceProtocol { get }
    var walletBuilder: WalletBuilderProtocol { get }
    var walletLifecycleService: WalletLifecycleServiceProtocol { get }
    var fiatService: FiatServiceProtocol { get }
    var feeService: FeeServiceProtocol { get }
    var moneroUriParser: MoneroUriParserProtocol { get }
    var watchCommunicationService: WatchCommunicationServiceProtocol { get }
    var twoFactorAuthenticationService: TwoFactorAuthenticationServiceProtocol { get }
}


public class IocContainer: IocContainerProtocol {

    public static let instance: IocContainerProtocol = IocContainer()
    
    public static var propertyStore: PropertyStoreProtocol {
        return  PropertyStore()
    }
    
    public static var secureStore: SecureStoreProtocol {
        return SecureStore()
    }
    
    public static var fileHandling: FileHandlingProtocol {
        return FileHandling()
    }

    public static var localizer: Localizable {
        return Localization(languageId: self.propertyStore.language)
    }
    
    public lazy var moneroBag: MoneroBagProtocol = {
        let moneroBag = MoneroBag()
        moneroBag.wallet = nil
        return moneroBag
    }()
    
    public lazy var onboardingService: OnboardingServiceProtocol = {
        let onboardingService = OnboardingService(walletBuilder: self.walletBuilder,
                                                  propertyStore: IocContainer.propertyStore,
                                                  secureStore: IocContainer.secureStore)
        return onboardingService
    }()
    
    public lazy var walletBuilder: WalletBuilderProtocol = {
        let walletBuilder = WalletBuilder(propertyStore: IocContainer.propertyStore,
                                          secureStore: IocContainer.secureStore,
                                          fileHandling: IocContainer.fileHandling)
        return walletBuilder
    }()
    
    public lazy var walletLifecycleService: WalletLifecycleServiceProtocol = {
        let walletLifecycleService = WalletLifecycleService(propertyStore: IocContainer.propertyStore,
                                                            secureStore: IocContainer.secureStore,
                                                            walletBuilder: self.walletBuilder)
        return walletLifecycleService
    }()

    public lazy var fiatService: FiatServiceProtocol = {
        let fiatService = FiatService(fiatProvider: self.fiatProvider,
                                      dateProvider: self.dateProvider,
                                      propertyStore: IocContainer.propertyStore)
        return fiatService
    }()
    
    public lazy var feeService: FeeServiceProtocol = {
        let feeService = FeeService(feeProvider: self.feeProvider,
                                    propertyStore: IocContainer.propertyStore)
        return feeService
    }()
    
    public lazy var moneroUriParser: MoneroUriParserProtocol = {
        let moneroUriParser = MoneroUriParser()
        return moneroUriParser
    }()

    public lazy var watchCommunicationService: WatchCommunicationServiceProtocol = {
        let watchCommunicationService = WatchCommunicationService()
        return watchCommunicationService
    }()

    public lazy var twoFactorAuthenticationService: TwoFactorAuthenticationServiceProtocol = {
        let twoFactorAuthenticationService = TwoFactorAuthenticationService(watchCommunicationService: self.watchCommunicationService)
        return twoFactorAuthenticationService
    }()


    private lazy var fiatProvider: FiatProviderProtocol = {
        let fiatProvider = FiatProvider()
        return fiatProvider
    }()
    
    private lazy var feeProvider: FeeProviderProtocol = {
        let feeProvider = FeeProvider()
        return feeProvider
    }()
    
    private lazy var dateProvider: DateProviderProtocol = {
        let dateProvider = DateProvider()
        return dateProvider
    }()
}
