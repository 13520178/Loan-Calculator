//
//  LoanCompareController.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 8/29/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import UIKit
import StoreKit

class LoanCompareController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    let appDel = UIApplication.shared.delegate as! AppDelegate
  
    @IBOutlet weak var loanAmountTextfieldA: UITextField!
    @IBOutlet weak var loanAmountTextfieldB: UITextField!
    
    @IBOutlet weak var yearsTextfieldA: UITextField!
    @IBOutlet weak var yearsTextfieldB: UITextField!
    @IBOutlet weak var monthsTextfieldA: UITextField!
    @IBOutlet weak var monthsTextfieldB: UITextField!
    @IBOutlet weak var interestRateTextfieldA: UITextField!
    @IBOutlet weak var interestRateTextfieldB: UITextField!
    
    @IBOutlet weak var paymentFrequencyButtonA: UIButton!
    @IBOutlet weak var paymentFrequencyButtonB: UIButton!
    
    @IBOutlet weak var inputShadowView: UIView!
    @IBOutlet weak var moveLoanAmountButton: UIButton!
    @IBOutlet weak var moveYearsButton: UIButton!
    @IBOutlet weak var moveMonthsButton: UIButton!
    @IBOutlet weak var moveInterestRateButton: UIButton!
    
    @IBOutlet weak var paymentLabelA: UILabel!
    @IBOutlet weak var paymentLabelB: UILabel!
    @IBOutlet weak var numberOfPaymentLabelA: UILabel!
    @IBOutlet weak var numberOfPaymentLabelB: UILabel!
    @IBOutlet weak var totalInterestLabelA: UILabel!
    @IBOutlet weak var totalInterestLabelB: UILabel!
    @IBOutlet weak var totalRepaidLabelA: UILabel!
    @IBOutlet weak var totalRepaidLabelB: UILabel!

    let defaults = UserDefaults.standard
    
    @IBOutlet weak var calculateButton: UIButton!
    
    
    var paymentFrequencyIndexForInputPageA = 2
    var paymentFrequencyIndexForInputPageB = 2
    
    var paymentA = 0.0
    var numberOfPaymentA = 0.0
    var totalInterestA = 0.0
    var totalRepaidA = 0.0
    
    var paymentB = 0.0
    var numberOfPaymentB = 0.0
    var totalInterestB = 0.0
    var totalRepaidB = 0.0
    
    var products: [SKProduct] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("OK")
        loanAmountTextfieldA.delegate = self
        loanAmountTextfieldB.delegate = self
        yearsTextfieldA.delegate = self
        yearsTextfieldB.delegate = self
        monthsTextfieldA.delegate = self
        monthsTextfieldB.delegate = self
        interestRateTextfieldA.delegate = self
        interestRateTextfieldB.delegate = self

        appDel.myOrientation = .landscape
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        
        loanAmountTextfieldA.setBottomBorderOnCompareController()
        loanAmountTextfieldB.setBottomBorderOnCompareController()
        
        yearsTextfieldA.setBottomBorderOnCompareController()
        yearsTextfieldB.setBottomBorderOnCompareController()
        
        monthsTextfieldA.setBottomBorderOnCompareController()
        monthsTextfieldB.setBottomBorderOnCompareController()
        
        interestRateTextfieldA.setBottomBorderOnCompareController()
        interestRateTextfieldB.setBottomBorderOnCompareController()
        
        calculateButton.applySoftShadow()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        appDel.myOrientation = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        
        loanAmountTextfieldA.resignFirstResponder()
        monthsTextfieldA.resignFirstResponder()
        yearsTextfieldA.resignFirstResponder()
        interestRateTextfieldA.resignFirstResponder()
        
        loanAmountTextfieldB.resignFirstResponder()
        monthsTextfieldB.resignFirstResponder()
        yearsTextfieldB.resignFirstResponder()
        interestRateTextfieldB.resignFirstResponder()
    }
    

    @IBAction func paymentFrequencyButtonAPressed(_ sender: Any) {
        AlertService.showPaymentFrequency(in: self) { (index) in
            if index == 0 {
                self.paymentFrequencyButtonA.setTitle(StringForLocal.daily, for: .normal)
                self.paymentFrequencyIndexForInputPageA = 0
            }else if index == 1 {
                self.paymentFrequencyButtonA.setTitle(StringForLocal.weekly, for: .normal)
                self.paymentFrequencyIndexForInputPageA = 1
            }else if index == 2 {
                self.paymentFrequencyButtonA.setTitle(StringForLocal.monthly, for: .normal)
                self.paymentFrequencyIndexForInputPageA = 2
            }else if index == 3 {
                self.paymentFrequencyButtonA.setTitle(StringForLocal.quarterly, for: .normal)
                self.paymentFrequencyIndexForInputPageA = 3
            }else if index == 4 {
                self.paymentFrequencyButtonA.setTitle(StringForLocal.semiannually, for: .normal)
                self.paymentFrequencyIndexForInputPageA = 4
            }else if index == 5 {
                self.paymentFrequencyButtonA.setTitle(StringForLocal.annually, for: .normal)
                self.paymentFrequencyIndexForInputPageA = 5
            }
        }
    }

    @IBAction func paymentFrequencyButtonBPressed(_ sender: Any) {
        AlertService.showPaymentFrequency(in: self) { (index) in
            if index == 0 {
                self.paymentFrequencyButtonB.setTitle(StringForLocal.daily, for: .normal)
                self.paymentFrequencyIndexForInputPageB = 0
            }else if index == 1 {
                self.paymentFrequencyButtonB.setTitle(StringForLocal.weekly, for: .normal)
                self.paymentFrequencyIndexForInputPageB = 1
            }else if index == 2 {
                self.paymentFrequencyButtonB.setTitle(StringForLocal.monthly, for: .normal)
                self.paymentFrequencyIndexForInputPageB = 2
            }else if index == 3 {
                self.paymentFrequencyButtonB.setTitle(StringForLocal.quarterly, for: .normal)
                self.paymentFrequencyIndexForInputPageB = 3
            }else if index == 4 {
                self.paymentFrequencyButtonB.setTitle(StringForLocal.semiannually, for: .normal)
                self.paymentFrequencyIndexForInputPageB = 4
            }else if index == 5 {
                self.paymentFrequencyButtonB.setTitle(StringForLocal.annually, for: .normal)
                self.paymentFrequencyIndexForInputPageB = 5
            }
        }
    }

    @IBAction func clearButtonPressed(_ sender: Any) {
        yearsTextfieldA.text = ""
        monthsTextfieldA.text = ""
        loanAmountTextfieldA.text = ""
        interestRateTextfieldA.text = ""

        yearsTextfieldB.text = ""
        monthsTextfieldB.text = ""
        loanAmountTextfieldB.text = ""
        interestRateTextfieldB.text = ""
    }
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
        
        if !self.defaults.bool(forKey: "isRemoveAds"){
            if products.count >= 1 {
                AlertService.showInfoAlertAndComfirm(in: self, message: "\(StringForLocal.upgradeAndRemoveAdsDetails0) \(StringForLocal.upgradeToRemoveAdsAndUnlockAllFeature) \(Tools.priceFormatter.string(from: products[0].price)!)") { okOrRestore in
                    if okOrRestore {
                        //Purchase
                        if IAPHelper.canMakePayments(){
                            IAPProduct.store.buyProduct(self.products[0])
                        }
                    }else {
                        IAPProduct.store.restorePurchases()
                    }
                }
            }
        }else {
            calculate()
        }
    }
    
    func calculate() {
        self.view.endEditing(true)
        
        // Khai báo các biến
        var loanAmountA = 0.0, interestRateA = 0.0, loanAmountB = 0.0, interestRateB = 0.0
        var yearsA = 0, monthsA = 0, yearsB = 0, monthsB = 0

        // Parse Double
        guard normalizeDoubleInput(from: loanAmountTextfieldA, into: &loanAmountA),
              normalizeDoubleInput(from: interestRateTextfieldA, into: &interestRateA),
              normalizeDoubleInput(from: loanAmountTextfieldB, into: &loanAmountB),
              normalizeDoubleInput(from: interestRateTextfieldB, into: &interestRateB) else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.thereWasAnError)
            return
        }

        // Parse Int
        guard normalizeIntInput(from: yearsTextfieldA, into: &yearsA),
              normalizeIntInput(from: monthsTextfieldA, into: &monthsA),
              normalizeIntInput(from: yearsTextfieldB, into: &yearsB),
              normalizeIntInput(from: monthsTextfieldB, into: &monthsB) else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.thereWasAnError)
            return
        }

        // Validate các giá trị
        if loanAmountA < 0 || loanAmountB < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.loanAmountIsNotNegative)
            return
        }
        if interestRateA < 0 || interestRateB < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.interestRateIsNotNegative)
            return
        }
        if yearsA < 0 || yearsB < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.yearIsNotNegative)
            return
        }
        if monthsA < 0 || monthsB < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.monthIsNotNegative)
            return
        }
        if yearsA > 100 || yearsB > 100 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.theLoanTermTooBigYears)
            return
        }
        if monthsA > 1200 || monthsB > 1200 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.theLoanTermTooBigMonths)
            return
        }
        if interestRateA > 10000 || interestRateB > 10000 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.theLoanInterestRateTooBig)
            return
        }

        // Debug input
        print("===== DEBUG INPUTS =====")
        print("👉 Loan A:")
        print("  - Loan Amount A: \(loanAmountA)")
        print("  - Years A: \(yearsA)")
        print("  - Months A: \(monthsA)")
        print("  - Interest Rate A: \(interestRateA)")
        print("  - Frequency Index A: \(paymentFrequencyIndexForInputPageA)")
        print("👉 Loan B:")
        print("  - Loan Amount B: \(loanAmountB)")
        print("  - Years B: \(yearsB)")
        print("  - Months B: \(monthsB)")
        print("  - Interest Rate B: \(interestRateB)")
        print("  - Frequency Index B: \(paymentFrequencyIndexForInputPageB)")
        print("👉 Default decimal places: \(defaults.integer(forKey: "decimalPlaces"))")
        print("=========================")

        // Tính toán
        let numberForRound = pow(10.0, Double(defaults.integer(forKey: "decimalPlaces")))

        let resultA = LoanEMICalculator.calculatePayment(
            loanAmount: loanAmountA, years: yearsA, months: monthsA,
            interestRate: interestRateA, frequencyIndex: paymentFrequencyIndexForInputPageA
        )
        paymentA = (resultA.payment * numberForRound).rounded() / numberForRound
        totalRepaidA = (resultA.totalPayment * numberForRound).rounded() / numberForRound
        numberOfPaymentA = (resultA.numberOfPeriods * numberForRound).rounded() / numberForRound
        totalInterestA = ((totalRepaidA - loanAmountA) * numberForRound).rounded() / numberForRound

        let resultB = LoanEMICalculator.calculatePayment(
            loanAmount: loanAmountB, years: yearsB, months: monthsB,
            interestRate: interestRateB, frequencyIndex: paymentFrequencyIndexForInputPageB
        )
        paymentB = (resultB.payment * numberForRound).rounded() / numberForRound
        totalRepaidB = (resultB.totalPayment * numberForRound).rounded() / numberForRound
        numberOfPaymentB = (resultB.numberOfPeriods * numberForRound).rounded() / numberForRound
        totalInterestB = ((totalRepaidB - loanAmountB) * numberForRound).rounded() / numberForRound

        // Update UI A
        paymentLabelA.text = Tools.changeToCurrency(moneyStr: paymentA)
        numberOfPaymentLabelA.text = Tools.changeToCurrency(moneyStr: numberOfPaymentA)
        totalInterestLabelA.text = Tools.changeToCurrency(moneyStr: totalInterestA)
        totalRepaidLabelA.text = Tools.changeToCurrency(moneyStr: totalRepaidA)

        // Update UI B
        paymentLabelB.text = Tools.changeToCurrency(moneyStr: paymentB)
        numberOfPaymentLabelB.text = Tools.changeToCurrency(moneyStr: numberOfPaymentB)
        totalInterestLabelB.text = Tools.changeToCurrency(moneyStr: totalInterestB)
        totalRepaidLabelB.text = Tools.changeToCurrency(moneyStr: totalRepaidB)

        // Cuộn xuống cuối nếu là iPhone
        if UIDevice.current.userInterfaceIdiom != .pad {
            let offset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height - 24)
            scrollView.setContentOffset(offset, animated: true)
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
    
    @IBAction func moveLoanAmountButtonPressed(_ sender: Any) {
        loanAmountTextfieldB.text = loanAmountTextfieldA.text
    }
    
    @IBAction func moveYearsButtonPressed(_ sender: Any) {
        yearsTextfieldB.text = yearsTextfieldA.text
    }
    @IBAction func moveMonthButtonPressed(_ sender: Any) {
        monthsTextfieldB.text = monthsTextfieldA.text
        
    }
    @IBAction func moveInterestRateButtonPressed(_ sender: Any) {
        interestRateTextfieldB.text = interestRateTextfieldA.text
        
    }
    
    func normalizeDoubleInput(from textField: UITextField, into variable: inout Double) -> Bool {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
        if text.isEmpty {
            textField.text = "0"
            variable = 0
            return true
        }

        guard let number = Tools.parseNumber(from: text) else {
            return false
        }

        variable = number.doubleValue
        return true
    }

    func normalizeIntInput(from textField: UITextField, into variable: inout Int) -> Bool {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
        if text.isEmpty {
            textField.text = "0"
            variable = 0
            return true
        }

        guard let number = Tools.parseNumber(from: text) else {
            return false
        }

        variable = number.intValue
        return true
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        appDel.myOrientation = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        dismiss(animated: true, completion: nil)
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

extension UITextField {
    func setBottomBorderOnCompareController() {
        self.borderStyle = .none
        self.layer.masksToBounds = false
        self.layer.shadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0)
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension LoanCompareController {
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
