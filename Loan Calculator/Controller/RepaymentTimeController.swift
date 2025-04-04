//
//  RepaymentTimeController.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 8/27/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import UIKit
import StoreKit


class RepaymentTimeController: UIViewController,UITextFieldDelegate  {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var resultShadowView: UIView!
    @IBOutlet weak var inputShadowView: UIView!
    @IBOutlet weak var loanAmountTextfield: UITextField!
    @IBOutlet weak var paymentTextfield: UITextField!
    @IBOutlet weak var interestRateTextfield: UITextField!
    @IBOutlet weak var paymentFrequencyButton: UIButton!
    @IBOutlet weak var repaymentPeriodLabel: UILabel!
    @IBOutlet weak var numberOfPaymentLabel: UILabel!

    let defaults = UserDefaults.standard
    
    var products: [SKProduct] = []
    
    var paymentFrequencyIndexForInputPage = 2
    @IBOutlet weak var calculateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("OK")
        
        IAPProduct.store.delegate = self

        calculateButton.applySoftShadow()
        
        loanAmountTextfield.setBottomBorder()
        paymentTextfield.setBottomBorder()
        interestRateTextfield.setBottomBorder()
        
        loanAmountTextfield.delegate = self
        paymentTextfield.delegate = self
        interestRateTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        print("---- TEST -----") // 0 = DAY, 1 = WEEK, 2 = MONTH, 3 = YEAR
        print(calculateTime(numberOfPayment: 0.9, frequencyPaymentIndex: 4))
        print("----- END -----")
        
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
    

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        loanAmountTextfield.resignFirstResponder()
        paymentTextfield.resignFirstResponder()
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
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        print(self.defaults.bool(forKey: "isRemoveAds"))
        if !self.defaults.bool(forKey: "isRemoveAds"){
            if products.count >= 1 {
                performSegue(withIdentifier: "iap", sender: nil)
            }
        }else {
            calculate()
        }
        
    }
    
    func calculate() {
        self.view.endEditing(true)

        // ✅ Chuẩn hóa input rỗng
        [loanAmountTextfield, paymentTextfield, interestRateTextfield].forEach {
            if $0?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                $0?.text = "0"
            }
        }

        // ✅ Parse dữ liệu
        guard
            let loanAmountNum = Tools.parseNumber(from: loanAmountTextfield.text ?? ""),
            let paymentNum = Tools.parseNumber(from: paymentTextfield.text ?? ""),
            let interestRateNum = Tools.parseNumber(from: interestRateTextfield.text ?? "")
        else {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.thereWasAnError)
            return
        }

        let loanAmount = loanAmountNum.doubleValue
        let payment = paymentNum.doubleValue
        let interestRate = interestRateNum.doubleValue

        // ✅ Validate
        if loanAmount < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.loanAmountIsNotNegative)
            return
        }
        if interestRate < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.interestRateIsNotNegative)
            return
        }
        if payment < 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.paymentIsNotNegative)
            return
        }
        if payment == 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.paymentIsNotZeroOrBlank)
            return
        }
        if interestRate > 10000 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.theLoanInterestRateTooBig)
            return
        }
        if payment > loanAmount {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.youDoNotNeedALoan)
            return
        }

        // ✅ Tính thử suất trả gốc để đảm bảo hợp lệ
        let interestForCheck: Double = {
            switch paymentFrequencyIndexForInputPage {
            case 0: return interestRate / 36525
            case 1: return interestRate / 5200
            case 2: return interestRate / 1200
            case 3: return interestRate / 400
            case 4: return interestRate / 200
            case 5: return interestRate / 100
            default: return 0
            }
        }()

        let principalPortion = (payment - (interestForCheck * loanAmount)) / payment
        if principalPortion <= 0 {
            AlertService.showInfoAlert(in: self, title: StringForLocal.notification, message: StringForLocal.youCantCompleteTheLoan)
            return
        }

        // ✅ Tính số kỳ trả
        var numberOfPayment = paymentCalculator(
            loanAmount: loanAmount,
            payment: payment,
            interestRate: interestRate,
            paymentFrequencyIndex: paymentFrequencyIndexForInputPage
        )[0]

        // ✅ Gán giá trị ra giao diện
        repaymentPeriodLabel.text = calculateTime(
            numberOfPayment: numberOfPayment,
            frequencyPaymentIndex: paymentFrequencyIndexForInputPage
        )

        let numberForRound = pow(10.0, Double(defaults.integer(forKey: "decimalPlaces")))
        numberOfPayment = (numberOfPayment * numberForRound).rounded() / numberForRound
        numberOfPaymentLabel.text = Tools.changeToCurrency(moneyStr: numberOfPayment)

    }
    
    func calculateTime(numberOfPayment: Double, frequencyPaymentIndex: Int) -> String {
        var periods = numberOfPayment
        var year = 0
        var month = 0
        var day = 0
        
        let numberForRound: Double = (1.0 * pow(10.0, Double(defaults.integer(forKey: "decimalPlaces"))))
        
        if frequencyPaymentIndex == 0 { // DAY
            periods = periods.rounded(.up)
            if periods > Constant.DAYSPERYEAR {
                year = Int((periods / Constant.DAYSPERYEAR).rounded(.down))
                let numberOfDayForMonth = periods - (Constant.DAYSPERYEAR * Double(year))
                month = Int ((numberOfDayForMonth / Constant.DAYSPERMONTH).rounded(.down))
                let numberOfDayForDay = numberOfDayForMonth -  (Constant.DAYSPERMONTH * Double(month))
                day = Int(numberOfDayForDay.rounded(.up))

            }else if periods <= Constant.DAYSPERYEAR && periods > Constant.DAYSPERMONTH {
                if (numberOfPayment*numberForRound).rounded()/numberForRound == (Constant.DAYSPERYEAR*numberForRound).rounded()/numberForRound {
                    year = 1
                    month = 0
                    day = 0
                }else {
                    month = Int((periods / Constant.DAYSPERMONTH).rounded(.down))
                    let numberOfDayForDay = periods - (Constant.DAYSPERMONTH * Double(month))
                    day = Int(numberOfDayForDay.rounded(.up))
                }
               

            }else if periods <= Constant.DAYSPERMONTH && periods > 0 {
                if (numberOfPayment*numberForRound).rounded()/numberForRound == (Constant.DAYSPERMONTH*numberForRound).rounded()/numberForRound  {
                    year = 0
                    month = 1
                    day = 0
                }else {
                    day = Int(periods)
                    if Double(day) >= Constant.DAYSPERMONTH {
                        month = 1
                        day = Int((Double(day) - Constant.DAYSPERMONTH).rounded(.up))
                    }
                }
            }
        }else if frequencyPaymentIndex == 1 { // WEEK
            periods = periods.rounded(.up)
            if periods > Constant.WEEKSPERYEAR {
                year = Int((periods / Constant.WEEKSPERYEAR).rounded(.down))
                let numberOfWeekForMonth = periods - (Constant.WEEKSPERYEAR * Double(year))
                month = Int ((numberOfWeekForMonth / Constant.WEEKSPERMONTH).rounded(.down))
                let numberOfDayForDay = numberOfWeekForMonth - (Constant.WEEKSPERMONTH * Double(month))
                day = Int((numberOfDayForDay * Constant.DAYSPERWEEK).rounded(.up))
            }else if periods <= Constant.WEEKSPERYEAR && periods > Constant.WEEKSPERMONTH {
                month = Int((periods / Constant.WEEKSPERMONTH).rounded(.down))
                let numberOfDayForDay = periods - (Constant.WEEKSPERMONTH * Double(month))
                day = Int((numberOfDayForDay * Constant.DAYSPERWEEK).rounded(.up))
            }else if periods <= Constant.WEEKSPERMONTH {
                day = Int((periods  * Constant.DAYSPERWEEK).rounded(.up))
                if Double(day) >= Constant.DAYSPERMONTH {
                    month = 1
                    day = Int((Double(day) - Constant.DAYSPERMONTH).rounded(.up))
                }
            }
        }else if frequencyPaymentIndex == 2 { // MONTH
            periods = periods.rounded(.up)
            if periods > Constant.MONTHSPERYEAR {
                year = Int((periods / Constant.MONTHSPERYEAR).rounded(.down))
                let numberOfMonthForMonth = periods - (Constant.MONTHSPERYEAR * Double(year))
                month = Int(numberOfMonthForMonth.rounded(.up))
                if Double(month) > Constant.MONTHSPERYEAR {
                    year = year + 1
                    month = Int((Double(month) - Constant.MONTHSPERYEAR).rounded(.up))
                }
            }else if periods <= Constant.MONTHSPERYEAR {
                month = Int(periods)
            }
        }else if frequencyPaymentIndex == 3 {// QUARTER
            periods = periods.rounded(.up)
            if periods > Constant.QUARTERSPERYEAR {
                year = Int((periods/Constant.QUARTERSPERYEAR).rounded(.down))
                let numberOfQuarterForMonth = periods - (Constant.QUARTERSPERYEAR * Double(year))
                month = Int((numberOfQuarterForMonth * Constant.MONTHSPERQUARTER).rounded(.up))
                if Double(month) > Constant.MONTHSPERYEAR {
                    year = year + 1
                    month = Int((Double(month) - Constant.MONTHSPERYEAR).rounded(.up))
                }
            }else if periods <= Constant.QUARTERSPERYEAR {
                month = Int((Double(periods) * Constant.MONTHSPERQUARTER).rounded(.up))
                if Double(month) > Constant.MONTHSPERYEAR {
                    year = 1
                    month = Int((Double(month) - Constant.MONTHSPERYEAR).rounded(.up))
                }
            }
        }else if frequencyPaymentIndex == 4 {// SEMI-ANNUALLY
            periods = periods.rounded(.up)
            if periods > Constant.SEMIANNUALLYSPERYEAR {
                year = Int((periods / Constant.SEMIANNUALLYSPERYEAR).rounded(.down))
                let numberOfSemiAnnuallyForMonth = periods - (Constant.SEMIANNUALLYSPERYEAR * Double(year))
                month = Int((numberOfSemiAnnuallyForMonth * Constant.MONTHSPERSEMIANNUALLY).rounded(.up))
                if Double(month) > Constant.MONTHSPERYEAR {
                    year = year + 1
                    month = Int((Double(month) - Constant.MONTHSPERYEAR).rounded(.up))
                }
            }else if periods <= Constant.SEMIANNUALLYSPERYEAR {
                month = Int((Double(periods) * Constant.MONTHSPERSEMIANNUALLY).rounded(.up))
                if Double(month) > Constant.MONTHSPERYEAR {
                    year = 1
                    month = Int((Double(month) - Constant.MONTHSPERYEAR).rounded(.up))
                }
            }
        }else if frequencyPaymentIndex == 5 {// YEAR
            periods = periods.rounded(.up)
            year = Int(periods)
        }
        
        
        var yearTitle = ""
        var monthTitle = ""
        var dayTitle = ""
        
        if (year <= 1) {
            yearTitle = StringForLocal.year
        }else {
            yearTitle = StringForLocal.years
        }
        
        if (month <= 1) {
            monthTitle = StringForLocal.month
        }else {
            monthTitle = StringForLocal.months
        }
        
        if (day <= 1) {
            dayTitle = StringForLocal.day
        }else {
            dayTitle = StringForLocal.days
        }
        
        return "\(year) \(yearTitle) \(month) \(monthTitle) \(day) \(dayTitle)"
    }
    
    func paymentCalculator(loanAmount: Double , payment: Double, interestRate: Double, paymentFrequencyIndex: Int) -> [Double] {
        var interest = 0.0
        if (paymentFrequencyIndex == 0) {
            interest = interestRate / 36525
        }else if (paymentFrequencyIndex == 1) {
            interest = interestRate / 5200
        }else if (paymentFrequencyIndex == 2) {
            interest = interestRate / 1200
        }else if (paymentFrequencyIndex == 3) {
            interest = interestRate / 400
        }else if (paymentFrequencyIndex == 4) {
            interest = interestRate / 200
        }else if (paymentFrequencyIndex == 5) {
            interest = interestRate / 100
        }
        var result = 0.0
        if(interest == 0) {
             result = loanAmount / payment
        }else {
            let sub1 = log((payment - (interest * loanAmount))/payment)
            let sub2 = log(1 + interest)
            result = -(sub1/sub2)
        }
        
        var days = 0.0
        if (paymentFrequencyIndex == 0) {
            days = result
        }else if (paymentFrequencyIndex == 1) {
            days = (365.25 / 52) * result
        }else if (paymentFrequencyIndex == 2) {
            days = (365.25 / 12) * result
        }else if (paymentFrequencyIndex == 3) {
            days = result * (365.25 / 4)
        }else if (paymentFrequencyIndex == 4) {
            days = result * (365.25 / 2)
        }else if (paymentFrequencyIndex == 5) {
            days = result * 365.25
        }
        
        return [result,days]
      
    }
    
    @IBAction func showInterestRateInfo(_ sender: Any) {
        AlertService.showInfoAlert(in: self, title: StringForLocal.interestRate, message: StringForLocal.interestRateDefine)
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        loanAmountTextfield.text = ""
        paymentTextfield.text = ""
        interestRateTextfield.text = ""
        
        repaymentPeriodLabel.text = "0 \(StringForLocal.year) 0 \(StringForLocal.month)"
        numberOfPaymentLabel.text = "0"
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

extension RepaymentTimeController: IAPDoneMaking {
    func purchase(){
        reload()
    }
}

extension RepaymentTimeController {
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

