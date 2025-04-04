//
//  ToolsController.swift
//  Loan Calculator
//
//  Created by Đăng Phan on 26/3/25.
//  Copyright © 2025 Phan Đăng. All rights reserved.
//

import UIKit
import GoogleMobileAds
import StoreKit

class ToolsController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightFromInputToResultContraint: NSLayoutConstraint!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var loanCompareShadowView: UIView!
    @IBOutlet weak var loanComparionView: UIView!
    @IBOutlet weak var repaymentPeriodCalculatorView: UIView!
    @IBOutlet weak var repaymentPeriodShadowView: UIView!
    
    var products: [SKProduct] = []
    let isFirstTimeKey = "hasOpenedToolsControllerBefore" // ✅ Thêm key riêng cho màn Tools
    
    override func viewDidLoad() {
        super.viewDidLoad()//bannerView.adUnitID = ""
        
        loanCompareShadowView.layer.shadowColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        loanCompareShadowView.layer.shadowOpacity = 0.2
        loanCompareShadowView.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        loanCompareShadowView.layer.shadowRadius = 10
        
        repaymentPeriodShadowView.layer.shadowColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        repaymentPeriodShadowView.layer.shadowOpacity = 0.2
        repaymentPeriodShadowView.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        repaymentPeriodShadowView.layer.shadowRadius = 10
        
        let isFirstTime = !defaults.bool(forKey: isFirstTimeKey)
        
        if isFirstTime {
            print("🔹 Lần đầu mở ToolsController, không hiển thị quảng cáo.")
            defaults.set(true, forKey: isFirstTimeKey) // ✅ Ghi nhận đã mở lần đầu
        } else {
            if !defaults.bool(forKey: "isRemoveAds"){
                bannerView.delegate = self
                //bannerView.adUnitID = "ca-app-pub-9626752563546060/1778866437"
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Sample
                bannerView.rootViewController = self
            }
        }
        
        let loanComparisonTap = UITapGestureRecognizer(target: self, action: #selector(didTapLoanComparison))
        loanComparionView.addGestureRecognizer(loanComparisonTap)
        loanComparionView.isUserInteractionEnabled = true
        
        let repaymentTimeTap = UITapGestureRecognizer(target: self, action: #selector(didTapRepaymentTime))
        repaymentPeriodCalculatorView.addGestureRecognizer(repaymentTimeTap)
        repaymentPeriodCalculatorView.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        let isFirstTime = !defaults.bool(forKey: isFirstTimeKey)
        
        if !isFirstTime && !defaults.bool(forKey: "isRemoveAds") {
            if self.defaults.bool(forKey: "startShowAds") {
                self.loadBannerAd()
                self.bannerView.load(GADRequest())
            }
        } else {
            self.heightFromInputToResultContraint.constant = 0
            self.bannerView.isHidden = true
        }
    }
    
    // BANNER MAKING
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            let isFirstTime = !self.defaults.bool(forKey: self.isFirstTimeKey)
            if !isFirstTime &&
                !self.defaults.bool(forKey: "isRemoveAds") &&
                self.defaults.bool(forKey: "startShowAds") {
                self.loadBannerAd()
                self.bannerView.load(GADRequest())
            }
        })
    }
    
    func loadBannerAd() {
        // Step 2 - Determine the view width to use for the ad width.
        let frame = { () -> CGRect in
            // Here safe area is taken into account, hence the view frame is used
            // after the view has been laid out.
            if #available(iOS 11.0, *) {
                return view.frame.inset(by: view.safeAreaInsets)
            } else {
                return view.frame
            }
        }()
        let viewWidth = frame.size.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        bannerHeightConstraint.constant = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth).size.height
        print( bannerHeightConstraint.constant )
    }
    
    
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        if !self.defaults.bool(forKey: "isRemoveAds"){
            UIView.animate(withDuration: 1, animations: {
                self.heightFromInputToResultContraint.constant = bannerView.frame.height + 8
                //self.heightFromInputToResultContraint.constant = 0
            })
        }
    }
    
    @objc func didTapLoanComparison() {
        if !self.defaults.bool(forKey: "isRemoveAds"){
            if products.count >= 1 {
                performSegue(withIdentifier: "iap", sender: nil)
            }
        }else {
            performSegue(withIdentifier: "loanCompare", sender: self)
        }
    }

    @objc func didTapRepaymentTime() {
        if !self.defaults.bool(forKey: "isRemoveAds"){
            if products.count >= 1 {
                performSegue(withIdentifier: "iap", sender: nil)
            }
        }else {
            performSegue(withIdentifier: "repaymentPeriod", sender: self)
        }
    }

}
