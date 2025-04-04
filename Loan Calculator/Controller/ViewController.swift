//
//  ViewController.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 8/24/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import Charts


enum PaymentFrequency:String
{
    // Các phần ty
    case Daily = "Daily"
    case Weekly = "Weekly"
    case Monthly = "Monthly"
    case Quarterly = "Quarterly"
    case SemiAnnually = "Semi-Annually"
    case Annually = "Annually"
}

class ViewController: UIViewController,MFMailComposeViewControllerDelegate,GADBannerViewDelegate,GADFullScreenContentDelegate {
    
    var products: [SKProduct] = []
    var interstitial: GADInterstitialAd?
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inputShadowView: UIView!
    @IBOutlet weak var inpurView: UIView!
    
    @IBOutlet weak var loanAmountTextfield: UITextField!
    @IBOutlet weak var monthTextfield: UITextField!
    @IBOutlet weak var interestRateTextfield: UITextField!
    @IBOutlet weak var yearTextfield: UITextField!
    @IBOutlet weak var paymentFrequencyButton: UIButton!
    
    @IBOutlet weak var resultShadowView: UIView!
    @IBOutlet weak var resultView: UIView!
    
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var pieView: PieChartView!
    
    static var paymentFrequencyIndex = 2
    var paymentFrequencyIndexForInputPage = 2
    static var payment = 0.0
    static var numberOfPayment = 0.0
    static var loanTerm = ""
    static var interestRate = 0.0
    static var totalInterest = 0.0
    static var totalRepaid = 0.0
    static var years = 0
    static var months = 0
    static var loanAmount = 0.0
    static var amortizations = [Amortization]()
    static var isShowAmortization = false
    
    var loanAmountForSaving = 0.0
    var yearForSaving = 0
    var monthForSaving = 0
    var interestRateForSaving = 0.0
    var paymentFrequencyIndexForSaving = 0
    
    var hasLoadedInterstitialInSession = false
    
    @IBOutlet weak var paymentResultLabel: UILabel!
    @IBOutlet weak var numberOfPaymentResultLabel: UILabel!
    @IBOutlet weak var totalInterestResultLabel: UILabel!
    @IBOutlet weak var totalRepaidResultLabel: UILabel!
    @IBOutlet weak var paymentEveryPeriodTitleLabel: UILabel!
    
    @IBOutlet weak var chartContainerView: UIView!
    
    var bannerView: GADBannerView?
    @IBOutlet weak var adContainerView: UIView!
    @IBOutlet weak var adContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var heightFromInputViewToTopSafeArea: NSLayoutConstraint!
    @IBOutlet weak var upgradeButton: GradientButton!
    @IBOutlet weak var scheduleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults.integer(forKey: "decimalPlaces") == 0 {
            defaults.setValue(2, forKey: "decimalPlaces")
        }
        
        calculateButton.applySoftShadow()
        scheduleButton.applySoftShadow()

        paymentEveryPeriodTitleLabel.text =  "\(StringForLocal.paymentEveryMonth)"
        loanAmountTextfield.setBottomBorder()
        monthTextfield.setBottomBorder()
        yearTextfield.setBottomBorder()
        interestRateTextfield.setBottomBorder()
        
        loanAmountTextfield.delegate = self
        monthTextfield.delegate = self
        interestRateTextfield.delegate = self
        yearTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleIAPPurchase(_:)), name: .IAPHelperPurchaseNotification, object: nil)
        
        if !defaults.bool(forKey: "isRemoveAds") && defaults.bool(forKey: "startShowAds") {
            loadInlineBannerAd()
            createAndLoadInterstitial()
        } else {
            adContainerView.isHidden = true
            adContainerHeight.constant = 0
        }
        
        updateUpgradeButtonVisibility()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProduct()
        updateUpgradeButtonVisibility()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .IAPHelperPurchaseNotification, object: nil)
    }
    
    @objc func loadProduct() {
        products = []
        IAPProduct.store.requestProducts { [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products ?? []
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !self.defaults.bool(forKey: "isRemoveAds") &&
                    self.defaults.bool(forKey: "startShowAds") {
                    
                    self.loadInlineBannerAd()
                }
            }
        })
    }
    
    // 4. Hàm loadInlineBannerAd:
    func loadInlineBannerAd() {
        let width = adContainerView.bounds.width
        guard width > 0 else {
            print("⚠️ Width zero, thử lại sau.")
            return
        }

        let adSize = GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(width)
        let bannerView = GADBannerView(adSize: adSize)
        self.bannerView = bannerView
        //bannerView.adUnitID = "ca-app-pub-9626752563546060/5852066713"
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Test ID
        bannerView.rootViewController = self
        bannerView.delegate = self

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        adContainerView.subviews.forEach { $0.removeFromSuperview() }
        adContainerView.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: adContainerView.centerXAnchor),
            bannerView.topAnchor.constraint(equalTo: adContainerView.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: adContainerView.bottomAnchor)
        ])

        adContainerView.isHidden = true
        adContainerHeight.constant = 0
        bannerView.load(GADRequest())
    }

    // 5. Delegate methods:
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("✅ Inline ad received")
        adContainerView.isHidden = false
        adContainerHeight.constant = bannerView.frame.height
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("❌ Ad failed: \(error.localizedDescription)")
        adContainerView.isHidden = true
        adContainerHeight.constant = 0
    }
    
    
    // INTERSTITIAL MAKING
    func createAndLoadInterstitial() {
        //"ca-app-pub-9626752563546060/9765167664"
        //"ca-app-pub-3940256099942544/4411468910"
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
                               request: request,
                               completionHandler: { (ad, error) in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
        )
    }
    
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if !defaults.bool(forKey: "isRemoveAds"){
            createAndLoadInterstitial()
        }
    }
    
    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        loanAmountTextfield.resignFirstResponder()
        monthTextfield.resignFirstResponder()
        yearTextfield.resignFirstResponder()
        interestRateTextfield.resignFirstResponder()
    }
    
    
    
    @IBAction func paymentFrequencyButtonPressed(_ sender: Any) {
        AlertService.showPaymentFrequency(in: self) { (index) in
            if index == 0 {
                self.paymentFrequencyButton.setTitle("\(StringForLocal.daily)", for: .normal)
                self.paymentFrequencyIndexForInputPage = 0
            }else if index == 1 {
                self.paymentFrequencyButton.setTitle("\(StringForLocal.weekly)", for: .normal)
                self.paymentFrequencyIndexForInputPage = 1
            }else if index == 2 {
                self.paymentFrequencyButton.setTitle("\(StringForLocal.monthly)", for: .normal)
                self.paymentFrequencyIndexForInputPage = 2
            }else if index == 3 {
                self.paymentFrequencyButton.setTitle("\(StringForLocal.quarterly)", for: .normal)
                self.paymentFrequencyIndexForInputPage = 3
            }else if index == 4 {
                self.paymentFrequencyButton.setTitle("\(StringForLocal.semiannually)", for: .normal)
                self.paymentFrequencyIndexForInputPage = 4
            }else if index == 5 {
                self.paymentFrequencyButton.setTitle("\(StringForLocal.annually)", for: .normal)
                self.paymentFrequencyIndexForInputPage = 5
            }
        }
    }
    @IBAction func clearButtonPressed(_ sender: Any) {
        yearTextfield.text = ""
        monthTextfield.text = ""
        loanAmountTextfield.text = ""
        interestRateTextfield.text = ""
        
        paymentResultLabel.text = ""
        numberOfPaymentResultLabel.text = ""
        totalInterestResultLabel.text = ""
        totalRepaidResultLabel.text = ""
        
        ViewController.isShowAmortization = false
        
        // ✨ Xoá biểu đồ
        pieView.data = nil
        pieView.notifyDataSetChanged()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if ViewController.isShowAmortization {
            let currentDate = Date().string(format: "MM/dd/yyyy")
            AlertService.saveRecord(in: self) { (name, isSuccess) in
                if isSuccess {
                    if !CoreDataService.shared.saveRecord(createdDate: currentDate, loanAmount: self.loanAmountForSaving, years: self.yearForSaving, months: self.monthForSaving, interestRate: self.interestRateForSaving, payment: ViewController.payment, paymentFrequencyIndex: self.paymentFrequencyIndexForInputPage, name: name)
                    {
                        AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.anErrorOccurred)
                    }
                }else {
                    AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.pleaseDoNotLeaveTheNameBlank)
                }
            }
        }else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.pleaseTapCalculate)
        }
    }
    
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        if loanAmountTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            loanAmountTextfield.text = "0"
        }
        if interestRateTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            interestRateTextfield.text = "0"
        }
        if yearTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            yearTextfield.text = "0"
        }
        if monthTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            monthTextfield.text = "0"
        }
        
        // Xử lý giá trị rỗng
        let loanAmountStr = loanAmountTextfield.text ?? "0"
        let interestRateStr = interestRateTextfield.text ?? "0"
        let yearsStr = yearTextfield.text ?? "0"
        let monthsStr = monthTextfield.text ?? "0"
        
        // Parse số
        guard
            let loanAmountNum = Tools.parseNumber(from: loanAmountStr),
            let interestRateNum = Tools.parseNumber(from: interestRateStr),
            let yearsNum = Tools.parseNumber(from: yearsStr),
            let monthsNum = Tools.parseNumber(from: monthsStr)
        else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.thereWasAnError)
            return
        }
        
        let loanAmount = loanAmountNum.doubleValue
        let interestRate = interestRateNum.doubleValue
        let years = yearsNum.intValue
        let months = monthsNum.intValue
        
        // Validate input
        if loanAmount < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.loanAmountIsNotNegative)
            return
        }
        if interestRate < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.interestRateIsNotNegative)
            return
        }
        if years < 0 || months < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.monthIsNotNegative)
            return
        }
        if years > 100 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.theLoanTermTooBigYears)
            return
        }
        if months > 1200 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.theLoanTermTooBigMonths)
            return
        }
        if interestRate > 10000 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.theLoanInterestRateTooBig)
            return
        }
        
        // Tính toán kết quả
        let numberForRound = pow(10.0, Double(defaults.integer(forKey: "decimalPlaces")))
        let result = LoanEMICalculator.calculatePayment(
            loanAmount: loanAmount,
            years: years,
            months: months,
            interestRate: interestRate,
            frequencyIndex: paymentFrequencyIndexForInputPage
        )
        
        ViewController.payment = (result.payment * numberForRound).rounded() / numberForRound
        ViewController.paymentFrequencyIndex = paymentFrequencyIndexForInputPage
        ViewController.totalRepaid = (result.totalPayment * numberForRound).rounded() / numberForRound
        ViewController.numberOfPayment = (result.numberOfPeriods * numberForRound).rounded() / numberForRound
        ViewController.totalInterest = ((ViewController.totalRepaid - loanAmount) * numberForRound).rounded() / numberForRound
        ViewController.loanAmount = loanAmount
        ViewController.interestRate = interestRate
        ViewController.years = years
        ViewController.months = months
        
        paymentResultLabel.text = Tools.changeToCurrency(moneyStr: ViewController.payment) ?? "0"
        numberOfPaymentResultLabel.text = Tools.changeToCurrency(moneyStr: ViewController.numberOfPayment) ?? "0"
        totalInterestResultLabel.text = Tools.changeToCurrency(moneyStr: ViewController.totalInterest) ?? "0"
        totalRepaidResultLabel.text = Tools.changeToCurrency(moneyStr: ViewController.totalRepaid) ?? "0"
        
        // ✅ Sử dụng hàm tái sử dụng để lấy bảng khấu hao
        ViewController.amortizations = LoanEMICalculator.generateAmortizationSchedule(
            loanAmount: loanAmount,
            years: years,
            months: months,
            interestRate: interestRate,
            frequencyIndex: paymentFrequencyIndexForInputPage
        )
        
        paymentEveryPeriodTitleLabel.text = {
            switch paymentFrequencyIndexForInputPage {
            case 0: return StringForLocal.paymentEveryDay
            case 1: return StringForLocal.paymentEveryWeek
            case 2: return StringForLocal.paymentEveryMonth
            case 3: return StringForLocal.paymentEveryQuarter
            case 4: return StringForLocal.paymentEverySixMonth
            case 5: return StringForLocal.paymentEveryYear
            default: return ""
            }
        }()
        
        setupPieChart(loanAmount: ViewController.loanAmount, interestValue: ViewController.totalInterest)
        
        ViewController.isShowAmortization = true
        
        // Lưu để hiển thị lại sau
        loanAmountForSaving = ViewController.loanAmount
        interestRateForSaving = ViewController.interestRate
        yearForSaving = ViewController.years
        monthForSaving = ViewController.months
        paymentFrequencyIndexForSaving = paymentFrequencyIndexForInputPage
        
        let resultFrame = self.resultView.frame
        self.scrollView.scrollRectToVisible(resultFrame, animated: true)
    }
    
    @IBAction func showSchedule(_ sender: UIButton) {
        
        let shownScheduleCount = defaults.integer(forKey: "shownScheduleCount") + 1
        defaults.setValue(shownScheduleCount, forKey: "shownScheduleCount")
        
        // Nếu đã đủ điều kiện và quảng cáo chưa được load → load ngay
           if shownScheduleCount >= 2 &&
               !defaults.bool(forKey: "isRemoveAds") &&
               defaults.bool(forKey: "startShowAds") {

               if !hasLoadedInterstitialInSession {
                   createAndLoadInterstitial()
                   hasLoadedInterstitialInSession = true
                   print("📦 Đã load interstitial quảng cáo ngay tại showSchedule")
               }

               // Nếu đã load xong → hiển thị
               if let ad = self.interstitial {
                   ad.present(fromRootViewController: self)
               } else {
                   print("⚠️ Quảng cáo đang được load, chưa sẵn sàng")
               }
           }
        
        performSegue(withIdentifier: "schedule", sender: nil)
    }
    @IBAction func removeAdsButtonPressed(_ sender: UIButton) {
        if !defaults.bool(forKey: "isRemoveAds"){
            if products.count >= 1 {
                performSegue(withIdentifier: "iap", sender: nil)
            }
        }
    }
    
    @IBAction func emailResultButtonPressed(_ sender: UIBarButtonItem) {
        print(self.defaults.bool(forKey: "isRemoveAds"))
        if !self.defaults.bool(forKey: "isRemoveAds"){
            if products.count >= 1 {
                performSegue(withIdentifier: "iap", sender: nil)
            }
        }else {
            
            if ViewController.isShowAmortization {
                var yearTitle = ""
                var monthTitle = ""
                if ViewController.years > 1 {
                    yearTitle = StringForLocal.years
                }else {
                    yearTitle = StringForLocal.year
                }
                
                if ViewController.months > 1 {
                    monthTitle = StringForLocal.months
                }else {
                    monthTitle = StringForLocal.month
                }
                
                var paymentFrequencyValue = ""
                if paymentFrequencyIndexForSaving == 0 {
                    paymentFrequencyValue = StringForLocal.daily
                }else if paymentFrequencyIndexForSaving == 1 {
                    paymentFrequencyValue = StringForLocal.weekly
                }else if paymentFrequencyIndexForSaving == 2 {
                    paymentFrequencyValue = StringForLocal.monthly
                }else if paymentFrequencyIndexForSaving == 3 {
                    paymentFrequencyValue = StringForLocal.quarterly
                }else if paymentFrequencyIndexForSaving == 4 {
                    paymentFrequencyValue = StringForLocal.semiannually
                }else if paymentFrequencyIndexForSaving == 5 {
                    paymentFrequencyValue = StringForLocal.annually
                }
                
                var copyString = ""
                copyString =
                    """
            *****\(StringForLocal.input)*****
            \(StringForLocal.loanAmount): \(Tools.changeToCurrency(moneyStr: ViewController.loanAmount)!)
            \(StringForLocal.loanTerm): \(ViewController.years) \(yearTitle) \(ViewController.months) \(monthTitle)
            \(StringForLocal.interestRate): \(Tools.changeToCurrency(moneyStr: ViewController.interestRate)!)%
            \(StringForLocal.paymentFrequency): \(paymentFrequencyValue)
            
            *****\(StringForLocal.result)*****
            \(StringForLocal.payment):\(Tools.changeToCurrency(moneyStr: ViewController.payment)!)
            \(StringForLocal.numberOfPayment): \(Tools.changeToCurrency(moneyStr: ViewController.numberOfPayment)!)
            \(StringForLocal.totalInterest):  \(Tools.changeToCurrency(moneyStr: ViewController.totalInterest)!)
            \(StringForLocal.totalRepaid): \(Tools.changeToCurrency(moneyStr: ViewController.totalRepaid)!)
            
            """
                
                let mailComposeViewController = self.configureMailController(mailContent: copyString)
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showMailError()
                }
                print(copyString)
                
            }else {
                AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.pleaseTapCalculate)
            }
        }
        
        
    }
    
    func setupPieChart(loanAmount:Double, interestValue:Double) {
        pieView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        
        var entries: [PieChartDataEntry] = Array()
        entries.append(PieChartDataEntry(value: loanAmount, label: StringForLocal.loanAmount))
        entries.append(PieChartDataEntry(value: interestValue, label: StringForLocal.totalInterest))
        
        let dataSet = PieChartDataSet(entries: entries,label: "")
        
        dataSet.colors = [#colorLiteral(red: 1, green: 0.4980392157, blue: 0.2431372549, alpha: 1),#colorLiteral(red: 0.262745098, green: 0.2078431373, blue: 0.6549019608, alpha: 1)]
        dataSet.drawValuesEnabled = true
        dataSet.sliceSpace = 2.0
        
        
        pieView.usePercentValuesEnabled = true
        pieView.drawSlicesUnderHoleEnabled = false
        pieView.holeRadiusPercent = 0.40
        pieView.transparentCircleRadiusPercent = 0.43
        pieView.drawHoleEnabled = true
        pieView.rotationAngle = 0.0
        pieView.rotationEnabled = true
        pieView.highlightPerTapEnabled = false
        
        let pieChartLegend = pieView.legend
        pieChartLegend.horizontalAlignment = Legend.HorizontalAlignment.right
        pieChartLegend.verticalAlignment = Legend.VerticalAlignment.top
        pieChartLegend.orientation = Legend.Orientation.vertical
        pieChartLegend.drawInside = false
        pieChartLegend.yOffset = 10.0
        
        pieView.legend.enabled = true
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        
        
        let pieChartData = PieChartData(dataSet: dataSet)
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        pieView.data = pieChartData
        
        
    }
    
    
    func configureMailController(mailContent:String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject(StringForLocal.appName)
        mailComposerVC.setMessageBody(mailContent, isHTML: false)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "iap" {
            if let resultController = segue.destination as? IAPController {
                if products.count >= 1 {
                    resultController.price = Tools.priceFormatter.string(from: products[0].price)!
                }
            }
        }
    }
    
    func updateUpgradeButtonVisibility() {
        let hasRemovedAds = defaults.bool(forKey: "isRemoveAds")
        
        if hasRemovedAds {
            upgradeButton.isHidden = true
            heightFromInputViewToTopSafeArea.constant = 18
        } else {
            upgradeButton.isHidden = false
            heightFromInputViewToTopSafeArea.constant = 90
        }
    }
    
    @objc func handleIAPPurchase(_ notification: Notification) {
        print("🎯 Đã nhận thông báo mua thành công")
        
        loadProduct()

        let isRemoveAds = defaults.bool(forKey: "isRemoveAds")
        let startShowAds = defaults.bool(forKey: "startShowAds")
        print("🧾 isRemoveAds:", isRemoveAds)
        print("🧾 startShowAds:", startShowAds)

        if !isRemoveAds && startShowAds {
            loadInlineBannerAd()
        } else {
            adContainerView.isHidden = true
            adContainerHeight.constant = 0
            print("🛑 Đã ẩn quảng cáo")
        }
        
        updateUpgradeButtonVisibility()
    }
}


extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.masksToBounds = false
        self.layer.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let locale = Locale.current
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 20 // tạm thời cho thoải mái
        
        let allowedDecimals = UserDefaults.standard.integer(forKey: "decimalPlaces") // hoặc 2 mặc định
        
        let currentText = textField.text ?? ""
        let nsText = currentText as NSString
        let updatedText = nsText.replacingCharacters(in: range, with: string)
        
        // Nếu xoá hết
        if updatedText.isEmpty {
            return true
        }
        
        let decimalSeparator = formatter.decimalSeparator ?? "."
        
        // Cho gõ dấu thập phân nếu chưa có
        if string == decimalSeparator && !currentText.contains(decimalSeparator) {
            textField.text = currentText + decimalSeparator
            return false
        }
        
        // Đếm số chữ số sau dấu thập phân (nếu có)
        if let separatorRange = updatedText.range(of: decimalSeparator) {
            let afterDecimal = updatedText[separatorRange.upperBound...]
            if afterDecimal.count > allowedDecimals {
                return false // Đã vượt số chữ số cho phép
            }
        }
        
        // Lọc số và dấu
        let allowed = CharacterSet(charactersIn: "0123456789\(decimalSeparator)")
        let filtered = String(updatedText.unicodeScalars.filter { allowed.contains($0) })
        
        guard let number = formatter.number(from: filtered),
              let formatted = formatter.string(from: number) else {
            return false
        }
        
        textField.text = formatted
        
        // Nếu user đang gõ tiếp phần thập phân chưa đầy đủ thì giữ lại
        if updatedText.contains(decimalSeparator), !formatted.contains(decimalSeparator) {
            textField.text = formatted + decimalSeparator
        }
        
        return false
    }
}

