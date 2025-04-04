//
//  Tools.swift
//  HomeLoanCalculator
//
//  Created by Phan Nhat Dang on 11/27/19.
//  Copyright © 2019 Phan Nhat Dang. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class Tools {
    
    static let STARTSHOWINGINTER = 1
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    
    static func addDotToCurrencyString(money:String,cha:Character) -> String {
        var newMoney = money
        if newMoney.count == 4 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 1))
        }else if newMoney.count == 5 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 2))
        }else if newMoney.count == 6 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 3))
        }else if newMoney.count == 7 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 4))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 1))
        }else if newMoney.count == 8 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 5))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 2))
        }else if newMoney.count == 9 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 6))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 3))
        }else if newMoney.count == 10 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 7))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 4))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 1))
        }else if newMoney.count == 11 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 8))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 5))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 2))
        }else if newMoney.count == 12 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 9))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 6))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 3))
        }else if newMoney.count == 13 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 10))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 7))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 4))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 1))
        }else if newMoney.count == 14 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 11))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 8))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 5))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 2))
        }else if newMoney.count == 15 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 12))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 9))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 6))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 3))
        }else if newMoney.count == 16 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 13))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 10))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 7))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 4))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 1))
        }else if newMoney.count == 17 {
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 14))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 11))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 8))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 5))
            newMoney.insert(cha, at: money.index(money.startIndex, offsetBy: 2))
        }
        return newMoney
    }
    
    static func fixCurrencyTextInTextfield(moneyStr:String) ->String? {
        let defaults = UserDefaults.standard
        
        if StringForLocal.country == "US" || StringForLocal.country == "THAI" || StringForLocal.country == "KOREA" || StringForLocal.country == "MALAY" || StringForLocal.country == "JAPAN" || StringForLocal.country == "CHINA" || StringForLocal.country == "HKTW" {
            var afterFixString = moneyStr
            
            afterFixString = afterFixString.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)
            
            let numOfDot = moneyStr.components(separatedBy:".").count - 1
            if numOfDot > 1 {
                afterFixString = String(afterFixString.dropLast())
            }
            
            let commaStringArray = afterFixString.components(separatedBy: ".")
            var beforeCommaString = commaStringArray[0]
            if beforeCommaString.count >= 15 {
                beforeCommaString = String(beforeCommaString.dropLast())
            }
            beforeCommaString = Tools.addDotToCurrencyString(money: beforeCommaString, cha: ",")
            
            print(beforeCommaString)
            
            if commaStringArray.count == 2 {
                var afterCommaString = commaStringArray[1]
                if afterCommaString.count > defaults.integer(forKey: "decimalPlaces") {
                    afterCommaString = String(afterCommaString.dropLast())
                }
                print(afterCommaString)
                return beforeCommaString + "." + afterCommaString
            }
            return beforeCommaString
        }else if StringForLocal.country == "VN" || StringForLocal.country == "BRA" || StringForLocal.country == "SPA" || StringForLocal.country == "HALAN" || StringForLocal.country == "INDO" || StringForLocal.country == "ITA" {
            var afterFixString = moneyStr
            
            afterFixString = afterFixString.replacingOccurrences(of: ".", with: "", options: .literal, range: nil)
            
            let numOfDot = moneyStr.components(separatedBy:",").count - 1
            if numOfDot > 1 {
                afterFixString = String(afterFixString.dropLast())
            }
            
            let commaStringArray = afterFixString.components(separatedBy: ",")
            var beforeCommaString = commaStringArray[0]
            if beforeCommaString.count >= 15 {
                beforeCommaString = String(beforeCommaString.dropLast())
            }
            beforeCommaString = Tools.addDotToCurrencyString(money: beforeCommaString, cha: ".")
            
            print(beforeCommaString)
            
            if commaStringArray.count == 2 {
                var afterCommaString = commaStringArray[1]
                if afterCommaString.count > defaults.integer(forKey: "decimalPlaces") {
                    afterCommaString = String(afterCommaString.dropLast())
                }
                print(afterCommaString)
                return beforeCommaString + "," + afterCommaString
            }
            return beforeCommaString
        }else if StringForLocal.country == "PO"  || StringForLocal.country == "RUS" || StringForLocal.country == "FR" {
            var afterFixString = moneyStr
            
            afterFixString = afterFixString.stringByRemovingWhitespaces
            
            let numOfDot = moneyStr.components(separatedBy:",").count - 1
            if numOfDot > 1 {
                afterFixString = String(afterFixString.dropLast())
            }
            
            let commaStringArray = afterFixString.components(separatedBy: ",")
            var beforeCommaString = commaStringArray[0]
            if beforeCommaString.count >= 15 {
                beforeCommaString = String(beforeCommaString.dropLast())
            }
            beforeCommaString = Tools.addDotToCurrencyString(money: beforeCommaString, cha: " ")
            
            print(beforeCommaString)
            
            if commaStringArray.count == 2 {
                var afterCommaString = commaStringArray[1]
                if afterCommaString.count > defaults.integer(forKey: "decimalPlaces") {
                    afterCommaString = String(afterCommaString.dropLast())
                }
                print(afterCommaString)
                return beforeCommaString + "," + afterCommaString
            }
            return beforeCommaString
        }else {
            var afterFixString = moneyStr
            
            afterFixString = afterFixString.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)
            
            let numOfDot = moneyStr.components(separatedBy:".").count - 1
            if numOfDot > 1 {
                afterFixString = String(afterFixString.dropLast())
            }
            
            let commaStringArray = afterFixString.components(separatedBy: ".")
            var beforeCommaString = commaStringArray[0]
            if beforeCommaString.count >= 15 {
                beforeCommaString = String(beforeCommaString.dropLast())
            }
            beforeCommaString = Tools.addDotToCurrencyString(money: beforeCommaString, cha: ",")
            
            print(beforeCommaString)
            
            if commaStringArray.count == 2 {
                var afterCommaString = commaStringArray[1]
                if afterCommaString.count > defaults.integer(forKey: "decimalPlaces") {
                    afterCommaString = String(afterCommaString.dropLast())
                }
                print(afterCommaString)
                return beforeCommaString + "." + afterCommaString
            }
            return beforeCommaString
        }
        
    }
    
    static func changeToCurrency(moneyStr:Double) ->String? {
        let defaults = UserDefaults.standard
        let number = moneyStr
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = defaults.integer(forKey: "decimalPlaces")
        formatter.numberStyle = NumberFormatter.Style.decimal
        return formatter.string(from: NSNumber(value: number))
    }
    
    static func parseNumber(from text: String) -> NSNumber? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter.number(from: text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    static func createAmortizationCSV(
        amortizations: [Amortization],
        title: String,
        from controller: UIViewController
    ) {
        let numberForRound = pow(10.0, Double(UserDefaults.standard.integer(forKey: "decimalPlaces")))
        let decimalFormatter = NumberFormatter()
        decimalFormatter.locale = Locale.current
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.minimumFractionDigits = 0
        decimalFormatter.maximumFractionDigits = UserDefaults.standard.integer(forKey: "decimalPlaces")
        
        var csv = "#,\(StringForLocal.balance),\(StringForLocal.interest),\(StringForLocal.principal)\n\n"
        
        for a in amortizations {
            let rBalance = (a.balance * numberForRound).rounded() / numberForRound
            let rInterest = (a.interest * numberForRound).rounded() / numberForRound
            let rPrincipal = (a.principal * numberForRound).rounded() / numberForRound
            
            let bStr = decimalFormatter.string(from: NSNumber(value: rBalance)) ?? "\(rBalance)"
            let iStr = decimalFormatter.string(from: NSNumber(value: rInterest)) ?? "\(rInterest)"
            let pStr = decimalFormatter.string(from: NSNumber(value: rPrincipal)) ?? "\(rPrincipal)"
            
            csv += "\(a.number),\(bStr),\(iStr),\(pStr)\n"
        }
        
        do {
            let path = try FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("LoanAmortizationSchedule.csv")
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let activity = UIActivityViewController(activityItems: [title, fileURL], applicationActivities: nil)
            if let popover = activity.popoverPresentationController {
                popover.sourceView = controller.view
                popover.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            controller.present(activity, animated: true)
        } catch {
            print("❌ Error exporting CSV: \(error.localizedDescription)")
        }
    }
    
    static func generateEMIEmailContent(from info: LoanCalculationInfo) -> String {
        let yearTitle = info.years > 1 ? StringForLocal.years : StringForLocal.year
        let monthTitle = info.months > 1 ? StringForLocal.months : StringForLocal.month
        
        let paymentFrequencyValue: String = {
            switch info.paymentFrequencyIndex {
            case 0: return StringForLocal.daily
            case 1: return StringForLocal.weekly
            case 2: return StringForLocal.monthly
            case 3: return StringForLocal.quarterly
            case 4: return StringForLocal.semiannually
            case 5: return StringForLocal.annually
            default: return ""
            }
        }()
        
        return """
            *****\(StringForLocal.input)*****
            \(StringForLocal.loanAmount): \(Tools.changeToCurrency(moneyStr: info.loanAmount)!)
            \(StringForLocal.loanTerm): \(info.years) \(yearTitle) \(info.months) \(monthTitle)
            \(StringForLocal.interestRate): \(Tools.changeToCurrency(moneyStr: info.interestRate)!)%
            \(StringForLocal.paymentFrequency): \(paymentFrequencyValue)
            
            *****\(StringForLocal.result)*****
            \(StringForLocal.payment): \(Tools.changeToCurrency(moneyStr: info.payment)!)
            \(StringForLocal.numberOfPayment): \(Tools.changeToCurrency(moneyStr: info.numberOfPayment)!)
            \(StringForLocal.totalInterest): \(Tools.changeToCurrency(moneyStr: info.totalInterest)!)
            \(StringForLocal.totalRepaid): \(Tools.changeToCurrency(moneyStr: info.totalRepaid)!)
            """
    }
    
    
}

extension String {
    var stringByRemovingWhitespaces: String {
        return components(separatedBy: .whitespaces).joined()
    }
    
}


extension UIButton {
    func applySoftShadow(
        color: UIColor = .black,
        opacity: Float = 0.12,
        offset: CGSize = CGSize(width: 0, height: 4),
        radius: CGFloat = 4,
        cornerRadius: CGFloat = 12
    ) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
        self.layer.cornerRadius = cornerRadius
    }
}


