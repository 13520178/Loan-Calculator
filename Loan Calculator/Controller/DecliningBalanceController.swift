//
//  DecliningBalanceController.swift
//  Loan Calculator
//
//  Created by Đăng Phan on 4/4/25.
//  Copyright © 2025 Phan Đăng. All rights reserved.
//

import UIKit
import Charts

class DecliningBalanceController: UIViewController {
    
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
    
    @IBOutlet weak var paymentResultLabel: UILabel!
    @IBOutlet weak var numberOfPaymentResultLabel: UILabel!
    @IBOutlet weak var totalInterestResultLabel: UILabel!
    @IBOutlet weak var totalRepaidResultLabel: UILabel!
    @IBOutlet weak var paymentEveryPeriodTitleLabel: UILabel!
    
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var scheduleButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    static var paymentFrequencyIndex = 2
    var paymentFrequencyIndexForInputPage = 2
    
    var scheduleResult: [ReducingBalanceRepaymentSchedule] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        // Gán giá trị mặc định nếu rỗng
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
        
        // Lấy giá trị chuỗi
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
        
        // Gán giá trị đã parse
        let loanAmount = loanAmountNum.doubleValue
        let interestRate = interestRateNum.doubleValue
        let years = yearsNum.intValue
        let months = monthsNum.intValue
        let loanDurationInMonths = years * 12 + months
        
        // Validate
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
        
        // Tính toán dư nợ giảm dần
        let repaymentFreq = RepaymentFrequency(rawValue: paymentFrequencyIndexForInputPage) ?? .monthly
        let calculator = LoanReducingBalanceCalculator(
            loanAmount: loanAmount,
            annualInterestRate: interestRate,
            loanDurationInMonths: loanDurationInMonths,
            repaymentFrequency: repaymentFreq,
            startDate: Date()
        )
        
        let schedule = calculator.calculateSchedule()
        let numberForRound = pow(10.0, Double(defaults.integer(forKey: "decimalPlaces")))
        
        // Tính toán và làm tròn
        let firstPayment = ((schedule.first?.totalPayment ?? 0) * numberForRound).rounded() / numberForRound
        let lastPayment = ((schedule.last?.totalPayment ?? 0) * numberForRound).rounded() / numberForRound
        let totalPayment = (schedule.reduce(0) { $0 + $1.totalPayment } * numberForRound).rounded() / numberForRound
        let totalInterest = ((totalPayment - loanAmount) * numberForRound).rounded() / numberForRound
        let numberOfPeriods = Double(schedule.count)
        
        // Hiển thị kết quả
        paymentResultLabel.text = "\(StringForLocal.from) \(Tools.changeToCurrency(moneyStr: firstPayment) ?? "") \(StringForLocal.to) \(Tools.changeToCurrency(moneyStr: lastPayment) ?? "")"
        numberOfPaymentResultLabel.text = Tools.changeToCurrency(moneyStr: numberOfPeriods) ?? "0"
        totalInterestResultLabel.text = Tools.changeToCurrency(moneyStr: totalInterest) ?? "0"
        totalRepaidResultLabel.text = Tools.changeToCurrency(moneyStr: totalPayment) ?? "0"
        
        // Cập nhật tiêu đề kỳ thanh toán
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
        
        // Biểu đồ
        setupPieChart(loanAmount: loanAmount, interestValue: totalInterest)
        scheduleResult = schedule
        ViewController.isShowAmortization = true
        
        // Scroll đến kết quả
        let resultFrame = self.resultView.frame
        self.scrollView.scrollRectToVisible(resultFrame, animated: true)
    }
    
    
    
    @IBAction func showSchedule(_ sender: UIButton) {
        performSegue(withIdentifier: "showDecliningSchedule", sender: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDecliningSchedule" {
            if let scheduleVC = segue.destination as? DecliningScheduleController {
                scheduleVC.schedule = scheduleResult
            }
        }
    }
    
}

extension DecliningBalanceController: UITextFieldDelegate {
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

