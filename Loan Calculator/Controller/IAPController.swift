//
//  IAPController.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 9/20/21.
//  Copyright © 2021 Phan Đăng. All rights reserved.
//

import UIKit
import StoreKit
import GoogleMobileAds
import FirebaseAnalytics

enum PremiumFeature {
    case repaymentCalculator
    case loanComparison
    case decliningBalance
    case exportCSV
    case emailResults
    case decimalSetting
    case removeAds
    case save
    case unknown // phòng trường hợp dự phòng
    
    var title: String {
        switch self {
        case .repaymentCalculator: return "Repayment Calculator"
        case .loanComparison: return "Loan Comparison"
        case .decliningBalance: return "Declining Balance"
        case .exportCSV: return "Export to CSV"
        case .emailResults: return "Email Results"
        case .decimalSetting: return "Decimal Setting"
        case .removeAds: return "Remove Ads"
        case .save: return "Save"
        case .unknown: return "Unknown Feature"
        }
    }
    
    var supportsAdUnlock: Bool {
        switch self {
        case .repaymentCalculator, .loanComparison, .save, .decliningBalance:
            return true
        default:
            return false
        }
    }
}

class IAPController: UIViewController {
    
    var products: [SKProduct] = []
    var price = ""
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mainInputView: UIView!
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var premiumLabel: UILabel!
    @IBOutlet weak var backLabel: UIButton!
    @IBOutlet weak var upgradeToRemoveAdsAndUnlockAllFeatureLabel: UILabel!
    @IBOutlet weak var calculateLoanPeriodsLabel: UILabel!
    @IBOutlet weak var compareLoansLabel: UILabel!
    @IBOutlet weak var emailTheResultLabel: UILabel!
    @IBOutlet weak var exportToCSVLabel: UILabel!
    @IBOutlet weak var setDecimalPlacesLabel: UILabel!
    @IBOutlet weak var removeAdsLabel: UILabel!
    @IBOutlet weak var supportOurDevelopmentLabel: UILabel!
    @IBOutlet weak var lifetimeUpgradeLabel: UILabel!
    @IBOutlet weak var upgradeLabel: UIButton!
    @IBOutlet weak var watchAdToUnlockButton: UIButton!
    
    var rewardedAd: GADRewardedAd?
    
    var featureToUnlock: PremiumFeature = .unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IAPProduct.store.delegate = self
        
        mainInputView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        premiumLabel.text = StringForLocal.premium
        backLabel.setTitle("x", for: .normal)
        upgradeToRemoveAdsAndUnlockAllFeatureLabel.text = StringForLocal.upgradeToRemoveAdsAndUnlockAllFeature
        calculateLoanPeriodsLabel.text = StringForLocal.calculateLoanPeriods
        compareLoansLabel.text = StringForLocal.compareLoans
        emailTheResultLabel.text = StringForLocal.emailTheResult
        exportToCSVLabel.text = StringForLocal.exportToCSV
        setDecimalPlacesLabel.text = StringForLocal.setDecimalPlaces
        removeAdsLabel.text = StringForLocal.removeAds
        supportOurDevelopmentLabel.text = StringForLocal.supportOurDevelopment
        //lifetimeUpgradeLabel.text = StringForLocal.lifeTimeUpgrade
        upgradeLabel.setTitle(StringForLocal.upgrade, for: .normal)
        
        watchAdToUnlockButton.layer.borderWidth = 1
        watchAdToUnlockButton.layer.borderColor = UIColor.label.cgColor
        
        loadRewardedAd()
        
        if featureToUnlock.supportsAdUnlock {
            watchAdToUnlockButton.isHidden = false
        } else {
            watchAdToUnlockButton.isHidden = true
        }
        
        Analytics.logEvent("show_iap", parameters: [
            "feature": featureToUnlock.title
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        
    }
    
    @objc func reload() {
        products = []
        IAPProduct.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products!
            }
        }
        
        
        priceLabel.text = "\(StringForLocal.lifeTimeUpgrade) \(price)"
        
        if defaults.bool(forKey: "isRemoveAds") {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    func loadRewardedAd() {
        let request = GADRequest()
        
        // Optional: Check for region (e.g., China) where AdMob may not work
        if let regionCode = Locale.current.regionCode, regionCode == "CN" {
            print("⚠️ AdMob may not be available in China")
            return
        }
        //ca-app-pub-9626752563546060/2748723313 - Main Ads ID
        //ca-app-pub-3940256099942544/1712485313 - Test ID
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Failed to load rewarded ad:", error)
                self.rewardedAd = nil
                return
            }
            
            self.rewardedAd = ad
            self.watchAdToUnlockButton.isEnabled = true
            print("✅ Rewarded ad loaded.")
        }
    }
    
    @IBAction func watchAdToUnlockButtonPressed(_ sender: UIButton) {
        guard let ad = rewardedAd else {
            let alert = UIAlertController(
                title: "\(StringForLocal.noAdAvailable)",
                message: "\(StringForLocal.adIsNotReadyYetPleaseTryAgainLater)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        ad.present(fromRootViewController: self) { [weak self] in
            guard let self = self else { return }
            
            let reward = ad.adReward
            print("🎉 User earned reward: \(reward.amount) \(reward.type)")
            
            Analytics.logEvent("rewarded_ad_completed", parameters: [
                "feature": self.featureToUnlock.title
            ])
            
            self.rewardedAd = nil
            self.loadRewardedAd()
            
            self.presentingViewController?.dismiss(animated: true) {
                NotificationCenter.default.post(name: .didUnlockFeature, object: self.featureToUnlock)
            }
        }
    }
    
    
    
    @IBAction func upgradeButtonPressed(_ sender: UIButton) {
        if products.count >= 1 {
            if IAPHelper.canMakePayments(){
                IAPProduct.store.buyProduct(self.products[0])
            }
        }
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension IAPController: IAPDoneMaking {
    func purchase(){
        reload()
    }
}

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first { $0.isKeyWindow }
    }
}
