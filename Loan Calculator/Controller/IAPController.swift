//
//  IAPController.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 9/20/21.
//  Copyright © 2021 Phan Đăng. All rights reserved.
//

import UIKit
import StoreKit

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
    @IBOutlet weak var notNowLabel: UIButton!
    
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
        lifetimeUpgradeLabel.text = StringForLocal.lifeTimeUpgrade
        upgradeLabel.setTitle(StringForLocal.upgrade, for: .normal)
        notNowLabel.setTitle(StringForLocal.notNow, for: .normal)
        

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
