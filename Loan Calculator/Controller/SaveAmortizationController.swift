//
//  SaveAmortizationController.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 9/4/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import UIKit
import GoogleMobileAds
import StoreKit

class SaveAmortizationController: UIViewController,UITableViewDelegate, UITableViewDataSource ,GADBannerViewDelegate {
  
    @IBOutlet weak var bannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightFromInputToResultContraint: NSLayoutConstraint!
    @IBOutlet weak var bannerView: GADBannerView!
    let defaults = UserDefaults.standard
    var products: [SKProduct] = []
    
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var amortizations = [Amortization]()
    var payment = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IAPProduct.store.delegate = self
        print("OK")
        if !defaults.bool(forKey: "isRemoveAds"){
            //Ads
            bannerView.delegate = self
            //bannerView.adUnitID = "ca-app-pub-9626752563546060/3582902690"
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //Sample
            bannerView.rootViewController = self
            //
            
        }
        

        tableView.delegate = self
        tableView.dataSource = self
        
        paymentLabel.text = "\(StringForLocal.payment): \(Tools.changeToCurrency(moneyStr: payment)!)"
        
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
        
        if !defaults.bool(forKey: "isRemoveAds"){
            if self.defaults.bool(forKey: "startShowAds") {
                self.loadBannerAd()
                self.bannerView.load(GADRequest())
            }
        }else {
            self.heightFromInputToResultContraint.constant = 0
        }
    }
    
    // BANNER MAKING
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(alongsideTransition: { _ in
            if !self.defaults.bool(forKey: "isRemoveAds") {
                if self.defaults.bool(forKey: "startShowAds") {
                    self.loadBannerAd()
                    self.bannerView.load(GADRequest())
                }
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
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        amortizations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let numberForRound = pow(10.0, Double(defaults.integer(forKey: "decimalPlaces")))
        let amortization = amortizations[indexPath.row]
        let isLargeLoan = amortizations.first?.balance ?? 0 >= 500_000_000

        // Làm tròn theo kiểu hiển thị
        let roundValue: (Double) -> Double = { value in
            let factor = isLargeLoan ? 1.0 : numberForRound
            return (value * factor).rounded() / factor
        }

        let roundedInterest = roundValue(amortization.interest)
        let roundedPrincipal = roundValue(amortization.principal)
        let roundedBalance = roundValue(amortization.balance)

        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell") as! ScheduleCell
        cell.numberLabel.text = "\(amortization.number)"
        cell.interestLabel.text = Tools.changeToCurrency(moneyStr: roundedInterest) ?? "-"
        cell.principalLabel.text = Tools.changeToCurrency(moneyStr: roundedPrincipal) ?? "-"
        cell.balanceLabel.text = Tools.changeToCurrency(moneyStr: roundedBalance) ?? "-"

        return cell
    }
    
    @IBAction func exportCSVButtonPressed(_ sender: UIBarButtonItem) {
        if !self.defaults.bool(forKey: "isRemoveAds"){
            if products.count >= 1 {
                performSegue(withIdentifier: "iap", sender: nil)
            }
        }else {
            createCSV(from: amortizations)
        }
    }
    
    func createCSV(from amortizations: [Amortization]) {
        Tools.createAmortizationCSV(
            amortizations: amortizations, // dùng tham số truyền vào
            title: StringForLocal.amortizationSchedule,
            from: self
        )
    }
  
}

extension SaveAmortizationController: IAPDoneMaking {
    func purchase(){
        reload()
    }
}

