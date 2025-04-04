//
//  DetailSavedController.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 9/4/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit
import Charts
import GoogleMobileAds

class DetailSavedController: UIViewController,UITextFieldDelegate,MFMailComposeViewControllerDelegate,GADBannerViewDelegate,GADFullScreenContentDelegate  {


    var bannerView: GADBannerView?
    @IBOutlet weak var adContainerView: UIView!
    @IBOutlet weak var adContainerHeight: NSLayoutConstraint!
    var interstitial: GADInterstitialAd?
    let defaults = UserDefaults.standard
    
    var products: [SKProduct] = []
    
    @IBOutlet weak var navItem: UINavigationItem!
    var selectedRow = 0
    @IBOutlet weak var inputShadowView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inpurView: UIView!
    
    @IBOutlet weak var loanAmountTextfield: UITextField!
    @IBOutlet weak var monthTextfield: UITextField!
    @IBOutlet weak var interestRateTextfield: UITextField!
    @IBOutlet weak var yearTextfield: UITextField!
    @IBOutlet weak var paymentFrequencyButton: UIButton!

    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var amortizationButton: UIButton!
    
    @IBOutlet weak var pieView: PieChartView!
    
    @IBOutlet weak var resultShadowView: UIView!
    @IBOutlet weak var chartShadowView: UIView!
    
    @IBOutlet weak var paymentEveryPeriodLabel: UILabel!
    @IBOutlet weak var paymentEveryPeriodTitleLabel: UILabel!
    @IBOutlet weak var numberOfPaymentLabel: UILabel!
    @IBOutlet weak var totalInterestLabel: UILabel!
    @IBOutlet weak var totalRepaidLabel: UILabel!
    
    var paymentFrequencyIndex = 2
    var paymentFrequencyIndexForInputPage = 2
    var payment = 0.0
    var numberOfPayment = 0.0
    var loanTerm = ""
    var interestRate = 0.0
    var totalInterest = 0.0
    var totalRepaid = 0.0
    var amortizations = [Amortization]()
    
    var loanAmountForSaving = 0.0
    var yearForSaving = 0
    var monthForSaving = 0
    var interestRateForSaving = 0.0
    var paymentFrequencyIndexForSaving = 0
    @IBOutlet weak var saveButton: UIButton!
    
    
    var records = [Record]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("OK")
        if !defaults.bool(forKey: "isRemoveAds") && defaults.bool(forKey: "startShowAds") {
            loadInlineBannerAd()
            createAndLoadInterstitial()
        } else {
            adContainerView.isHidden = true
            adContainerHeight.constant = 0
        }

        calculateButton.applySoftShadow()
        saveButton.applySoftShadow()
        amortizationButton.applySoftShadow()
        
        
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
        
        //Set textfield value and calculate
        records = CoreDataService.shared.loadRecordArray()
        let record = records[selectedRow]
        navItem.title = record.name
        
        loanAmountTextfield.text = Tools.changeToCurrency(moneyStr: record.loanAmount)
        monthTextfield.text =  String(record.months)
        yearTextfield.text =  String(record.years)
        interestRateTextfield.text = Tools.changeToCurrency(moneyStr: record.interestRate)
        
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor(named: "Blue App")?.cgColor
        
        if record.paymentFrequencyIndex == 0 {
            paymentFrequencyIndexForInputPage = 0
            self.paymentFrequencyButton.setTitle(StringForLocal.daily, for: .normal)
        }else if record.paymentFrequencyIndex == 1 {
            paymentFrequencyIndexForInputPage = 1
            self.paymentFrequencyButton.setTitle(StringForLocal.weekly, for: .normal)
        }else if record.paymentFrequencyIndex == 2 {
            paymentFrequencyIndexForInputPage = 2
            self.paymentFrequencyButton.setTitle(StringForLocal.monthly, for: .normal)
        }else if record.paymentFrequencyIndex == 3 {
            paymentFrequencyIndexForInputPage = 3
            self.paymentFrequencyButton.setTitle(StringForLocal.quarterly, for: .normal)
        }else if record.paymentFrequencyIndex == 4 {
            paymentFrequencyIndexForInputPage = 4
            self.paymentFrequencyButton.setTitle(StringForLocal.semiannually, for: .normal)
        }else if record.paymentFrequencyIndex == 5 {
            paymentFrequencyIndexForInputPage = 5
            self.paymentFrequencyButton.setTitle(StringForLocal.annually, for: .normal)
        }
        
        calculate()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadProduct()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .IAPHelperPurchaseNotification, object: nil)
    }
    
    @objc func loadProduct() {
        products = []
        IAPProduct.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products ?? []
            }
        }
    }
    
    func loadInlineBannerAd() {
        let width = adContainerView.bounds.width
        guard width > 0 else {
            print("⚠️ Width zero, thử lại sau.")
            return
        }

        let adSize = GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(width)
        let bannerView = GADBannerView(adSize: adSize)
        self.bannerView = bannerView
        //bannerView.adUnitID = "ca-app-pub-9626752563546060/1120390883"
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
    
    // BANNER MAKING
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
    
    // INTERSTITIAL MAKING
    func createAndLoadInterstitial() {
        //"ca-app-pub-9626752563546060/3267401440"
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
        //textFieldDidEndEditing(carPriceTextfield)
        loanAmountTextfield.resignFirstResponder()
        monthTextfield.resignFirstResponder()
        yearTextfield.resignFirstResponder()
        interestRateTextfield.resignFirstResponder()
    }

    
    @IBAction func paymentFrequencyButtonPressed(_ sender: Any) {
        AlertService.showPaymentFrequency(in: self) { (index) in
            if index == 0 {
                self.paymentFrequencyButton.setTitle(StringForLocal.daily, for: .normal)
                self.paymentFrequencyIndexForInputPage = 0
            }else if index == 1 {
                self.paymentFrequencyButton.setTitle(StringForLocal.weekly, for: .normal)
                self.paymentFrequencyIndexForInputPage = 1
            }else if index == 2 {
                self.paymentFrequencyButton.setTitle(StringForLocal.monthly, for: .normal)
                self.paymentFrequencyIndexForInputPage = 2
            }else if index == 3 {
                self.paymentFrequencyButton.setTitle(StringForLocal.quarterly, for: .normal)
                self.paymentFrequencyIndexForInputPage = 3
            }else if index == 4 {
                self.paymentFrequencyButton.setTitle(StringForLocal.semiannually, for: .normal)
                self.paymentFrequencyIndexForInputPage = 4
            }else if index == 5 {
                self.paymentFrequencyButton.setTitle(StringForLocal.annually, for: .normal)
                self.paymentFrequencyIndexForInputPage = 5
            }
        }
    }
    
    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        
        calculate()
        
    }
    
    func calculate() {
        self.view.endEditing(true)

        // ✅ Chuẩn hóa textField nếu bị rỗng
        [loanAmountTextfield, yearTextfield, monthTextfield, interestRateTextfield].forEach {
            if $0?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                $0?.text = "0"
            }
        }

        // ✅ Parse dữ liệu từ TextField
        guard
            let loanAmountNum = Tools.parseNumber(from: loanAmountTextfield.text ?? ""),
            let interestRateNum = Tools.parseNumber(from: interestRateTextfield.text ?? ""),
            let yearsNum = Tools.parseNumber(from: yearTextfield.text ?? ""),
            let monthsNum = Tools.parseNumber(from: monthTextfield.text ?? "")
        else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.thereWasAnError)
            return
        }

        let loanAmount = loanAmountNum.doubleValue
        let interestRate = interestRateNum.doubleValue
        let years = yearsNum.intValue
        let months = monthsNum.intValue

        // ✅ Validate logic
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

        // ✅ Tính toán
        let numberForRound = pow(10.0, Double(defaults.integer(forKey: "decimalPlaces")))
        let result = LoanEMICalculator.calculatePayment(
            loanAmount: loanAmount,
            years: years,
            months: months,
            interestRate: interestRate,
            frequencyIndex: paymentFrequencyIndexForInputPage
        )

        payment = (result.payment * numberForRound).rounded() / numberForRound
        totalRepaid = (result.totalPayment * numberForRound).rounded() / numberForRound
        numberOfPayment = (result.numberOfPeriods * numberForRound).rounded() / numberForRound
        totalInterest = ((totalRepaid - loanAmount) * numberForRound).rounded() / numberForRound
        paymentFrequencyIndex = paymentFrequencyIndexForInputPage

        amortizations = LoanEMICalculator.generateAmortizationSchedule(
            loanAmount: loanAmount,
            years: years,
            months: months,
            interestRate: interestRate,
            frequencyIndex: paymentFrequencyIndexForInputPage
        )

        // ✅ Lưu để export
        loanAmountForSaving = loanAmount
        interestRateForSaving = interestRate
        yearForSaving = years
        monthForSaving = months
        paymentFrequencyIndexForSaving = paymentFrequencyIndexForInputPage

        // ✅ Hiển thị UI
        paymentEveryPeriodLabel.text = Tools.changeToCurrency(moneyStr: payment)
        totalInterestLabel.text = Tools.changeToCurrency(moneyStr: totalInterest)
        totalRepaidLabel.text = Tools.changeToCurrency(moneyStr: totalRepaid)
        numberOfPaymentLabel.text = Tools.changeToCurrency(moneyStr: numberOfPayment)

        paymentEveryPeriodTitleLabel.text = {
            switch paymentFrequencyIndex {
            case 0: return StringForLocal.paymentEveryDay
            case 1: return StringForLocal.paymentEveryWeek
            case 2: return StringForLocal.paymentEveryMonth
            case 3: return StringForLocal.paymentEveryQuarter
            case 4: return StringForLocal.paymentEverySixMonth
            case 5: return StringForLocal.paymentEveryYear
            default: return ""
            }
        }()

        // ✅ Vẽ biểu đồ
        setupPieChart(loanAmount: loanAmount, interestValue: totalInterest)
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
         
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
        }else {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height - 24)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
        
        
    }
    
    func paymentCalculator(loanAmount: Double , years: Int, months: Int, interestRate: Double, paymentFrequencyIndex: Int) -> [Double] {
        var interest = 0.0
        var period = 0.0
        if (paymentFrequencyIndex == 0) {
            interest = interestRate / Constant.INTERESTPERDAY
            period = (Double(years) * 365.25) + ((365.25 / 12) * Double(months))
        }else if (paymentFrequencyIndex == 1) {
            interest = interestRate / Constant.INTERESTPERWEEK
            period = (Double(years) * 52) + ((52 / 12) * Double(months))
        }else if (paymentFrequencyIndex == 2) {
            interest = interestRate / Constant.INTERESTPERMONTH
            period = (Double(years) * 12) +  Double(months)
        }else if (paymentFrequencyIndex == 3) {
            interest = interestRate / Constant.INTERESTPERQUARTER
            period = (Double(years) * 4) + ((4 / 12) * Double(months))
        }else if (paymentFrequencyIndex == 4) {
            interest = interestRate / Constant.INTERESTPERSEMIANNUALLY
            period = (Double(years) * 2) + ((2 / 12) * Double(months))
        }else if (paymentFrequencyIndex == 5) {
            interest = interestRate / Constant.INTERESTPERYEAR
            period = Double(years) + ((1 / 12) * Double(months))
        }
        
        var payment = 0.0
        let sub1 = interest * loanAmount
        let sub2 = 1 - pow(1 + interest, -period)
        payment = sub1 / sub2
        
        if interestRate == 0 {
            payment = loanAmount / period
        }
        
        return [payment,payment * period,period,interest]
    }
    
    
    @IBAction func emailResultButtonPressed(_ sender: UIBarButtonItem) {
        
        if !self.defaults.bool(forKey: "isRemoveAds"){
            if products.count >= 1 {
                performSegue(withIdentifier: "iap", sender: nil)
            }
        }else {
            
            var yearTitle = ""
            var monthTitle = ""
            if yearForSaving > 1 {
                yearTitle = StringForLocal.years
            }else {
                yearTitle = StringForLocal.year
            }
            
            if monthForSaving > 1 {
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
            \(StringForLocal.loanAmount): \(Tools.changeToCurrency(moneyStr: loanAmountForSaving)!)
            \(StringForLocal.loanTerm): \(yearForSaving) \(yearTitle) \(monthForSaving) \(monthTitle)
            \(StringForLocal.interestRate): \(Tools.changeToCurrency(moneyStr: interestRateForSaving)!)%
            \(StringForLocal.paymentFrequency): \(paymentFrequencyValue)

            *****\(StringForLocal.result)*****
            \(StringForLocal.payment): \(payment)
            \(StringForLocal.numberOfPayment): \(numberOfPayment)
            \(StringForLocal.totalInterest): \(totalInterest)
            \(StringForLocal.totalRepaid): \(totalRepaid)

            """
            
            let mailComposeViewController = self.configureMailController(mailContent: copyString)
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showMailError()
            }
            print(copyString)
            
        }
        
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        records = CoreDataService.shared.loadRecordArray()
        records[selectedRow].loanAmount = loanAmountForSaving
        records[selectedRow].years = Int16(yearForSaving)
        records[selectedRow].months = Int16(monthForSaving)
        records[selectedRow].interestRate = interestRateForSaving
        records[selectedRow].paymentFrequencyIndex = Int16(paymentFrequencyIndexForSaving)
        
        
        if !CoreDataService.shared.saveAfterEditOrDelete() {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.anErrorOccurred)
        }else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: "Save successfully")
        }
        
    }
    
    @IBAction func showAmortizationButtonPressed(_ sender: UIButton) {
        
        if !self.defaults.bool(forKey: "isRemoveAds"){
            if let ad = self.interstitial {
              ad.present(fromRootViewController: self)
            } else {
              print("Ad wasn't ready")
            }
        }
        performSegue(withIdentifier: "showSavedAmortization", sender: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSavedAmortization",
            let destinationVC = segue.destination as? SaveAmortizationController {
            destinationVC.amortizations = amortizations
            destinationVC.payment = payment
        }
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

    @objc func handleIAPPurchase(_ notification: Notification) {
        print("🎯 Đã nhận thông báo mua thành công")

        // ✅ Nên thêm lại đoạn dưới:
        loadProduct()

        // ✅ Gợi ý thêm (giống ViewController):
        if !defaults.bool(forKey: "isRemoveAds") && defaults.bool(forKey: "startShowAds") {
            loadInlineBannerAd()
        } else {
            adContainerView.isHidden = true
            adContainerHeight.constant = 0
        }
    }
}

extension DetailSavedController {
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

