//
//  InfoController.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 8/25/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

class InfoController: UIViewController, MFMailComposeViewControllerDelegate,SKPaymentTransactionObserver {
    
    var products: [SKProduct] = []

    let defaults = UserDefaults.standard

    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var stairCalculatorView: UIView!
    @IBOutlet weak var autoLoanCalculatorView: UIView!
    @IBOutlet weak var restoreView: UIView!
    
    @IBOutlet weak var shareAppView: UIView!
    @IBOutlet weak var writeAReviewView: UIView!
    
    @IBOutlet weak var decimalPlacesView: UIView!
    @IBOutlet weak var decimalPlacesLabel: UILabel!
    @IBOutlet weak var decimalPlacesTitleLabel: UILabel!
    
    private let productURL = URL(string: "https://apps.apple.com/app/id1531071094")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IAPProduct.store.delegate = self
        
        SKPaymentQueue.default().add(self)
        
        let reportTap = UITapGestureRecognizer(target: self, action: #selector(sentMail))
        reportView.addGestureRecognizer(reportTap)
        
        let stairTap = UITapGestureRecognizer(target: self, action: #selector(openStair))
        stairCalculatorView.addGestureRecognizer(stairTap)
        
        let autoLoanTap = UITapGestureRecognizer(target: self, action: #selector(openAuto))
        autoLoanCalculatorView.addGestureRecognizer(autoLoanTap)
        
        let restoreTab = UITapGestureRecognizer(target: self, action: #selector(restoreIAP))
        restoreView.addGestureRecognizer(restoreTab)
        
        decimalPlacesTitleLabel.text = StringForLocal.decimalPlaces
        
        let decimalPlacesTab = UITapGestureRecognizer(target: self, action: #selector(decimalPlaces))
        decimalPlacesView.addGestureRecognizer(decimalPlacesTab)
        
        let shareAppTab = UITapGestureRecognizer(target: self, action: #selector(shareApp))
        shareAppView.addGestureRecognizer(shareAppTab)
        
        let writeReviewTab = UITapGestureRecognizer(target: self, action: #selector(writeReview))
        writeAReviewView.addGestureRecognizer(writeReviewTab)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        decimalPlacesLabel.text = String(defaults.integer(forKey: "decimalPlaces"))
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

    }
    
    @objc func shareApp() {
        // 1.
        let activityViewController = UIActivityViewController(
          activityItems: [productURL],
          applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // 2.
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func writeReview() {
        // 1.
        var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)
        
        // 2.
        components?.queryItems = [
          URLQueryItem(name: "action", value: "write-review")
        ]
        
        // 3.
        guard let writeReviewURL = components?.url else {
          return
        }
        
        // 4.
        UIApplication.shared.open(writeReviewURL)
    }
    
    
    @objc func decimalPlaces() {
        print(self.defaults.bool(forKey: "isRemoveAds"))
        if !self.defaults.bool(forKey: "isRemoveAds"){
            performSegue(withIdentifier: "iap", sender: nil)
        }else {
            AlertService.addDecimalPlacesAlert(in: self) { (number, isOk) in
                if !isOk {
                    AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.decimalPlaces0To8)
                }else {
                    self.defaults.set(number, forKey: "decimalPlaces")
                    self.decimalPlacesLabel.text = String(self.defaults.integer(forKey: "decimalPlaces"))
                }
            }
        }
    }
    
    
    @objc func restoreIAP() {
        IAPProduct.store.restorePurchases()
    }

    
    @objc func openStair() {
        if let url = URL(string: "https://apps.apple.com/app/mortgage-payment-calculator-nd/id1489668528"),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func openAuto() {
        if let url = URL(string: "https://apps.apple.com/app/auto-loan-calculator-payment/id1487930075"),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["phannhatd@gmail.com"])
        mailComposerVC.setSubject(StringForLocal.questionAbout)
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: StringForLocal.unableToSendMail, message: StringForLocal.unableToSendMailDefine, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @objc func sentMail() {
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
        
    }
    @IBAction func seeAllButtonPressed(_ sender: UIButton) {
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                defaults.set(true, forKey: "isRemoveAds")
                print("Transaction successful")
                SKPaymentQueue.default().finishTransaction(transaction)
                
            }else if transaction.transactionState == .failed {
                print("Transaction failed")
                SKPaymentQueue.default().finishTransaction(transaction)
            }else if transaction.transactionState == .restored {
                defaults.set(true, forKey: "isRemoveAds")
                print("Transaction successful")
                SKPaymentQueue.default().finishTransaction(transaction)
                print("ReStore ok")
                AlertService.showInfoAlert(in: self, title: "Restore", message: "Your restore has completed!")
                
            }
        }
    }
    
    func showOKAlert() {
        AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.restoreWasSuccessful)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "iap" {
            if let resultController = segue.destination as? IAPController {
                if products.count >= 1 {
                    resultController.price = Tools.priceFormatter.string(from: products[0].price)!
                }
            }
        }
    }
}

extension InfoController: IAPDoneMaking {
    func purchase(){
        showOKAlert()
    }
}
