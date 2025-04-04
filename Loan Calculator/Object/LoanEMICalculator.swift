//
//  LoanEMICalculator.swift
//  Loan Calculator
//
//  Created by Đăng Phan on 25/3/25.
//  Copyright © 2025 Phan Đăng. All rights reserved.
//

import Foundation

struct LoanCalculationInfo {
    let loanAmount: Double
    let years: Int
    let months: Int
    let interestRate: Double
    let paymentFrequencyIndex: Int
    let payment: Double
    let numberOfPayment: Double
    let totalInterest: Double
    let totalRepaid: Double
}

// MARK: - Amortization Model
struct Amortization {
    let number: Int
    let principal: Double
    let interest: Double
    var balance: Double
}

// MARK: - Payment Result
struct PaymentResult {
    let payment: Double
    let totalPayment: Double
    let numberOfPeriods: Double
    let interestPerPeriod: Double
}

// MARK: - EMI Calculator
class LoanEMICalculator {
    static func calculatePayment(
        loanAmount: Double,
        years: Int,
        months: Int,
        interestRate: Double,
        frequencyIndex: Int
    ) -> PaymentResult {
        
        var interestPerPeriod = 0.0
        var numberOfPeriods = 0.0
        
        switch frequencyIndex {
        case 0: // Daily
            interestPerPeriod = interestRate / Constant.INTERESTPERDAY
            numberOfPeriods = Double(years) * 365.25 + (365.25 / 12.0 * Double(months))
        case 1: // Weekly
            interestPerPeriod = interestRate / Constant.INTERESTPERWEEK
            numberOfPeriods = Double(years) * 52 + (52.0 / 12.0 * Double(months))
        case 2: // Monthly
            interestPerPeriod = interestRate / Constant.INTERESTPERMONTH
            numberOfPeriods = Double(years) * 12 + Double(months)
        case 3: // Quarterly
            interestPerPeriod = interestRate / Constant.INTERESTPERQUARTER
            numberOfPeriods = Double(years) * 4 + (4.0 / 12.0 * Double(months))
        case 4: // Semi-Annually
            interestPerPeriod = interestRate / Constant.INTERESTPERSEMIANNUALLY
            numberOfPeriods = Double(years) * 2 + (2.0 / 12.0 * Double(months))
        case 5: // Annually
            interestPerPeriod = interestRate / Constant.INTERESTPERYEAR
            numberOfPeriods = Double(years) + (1.0 / 12.0 * Double(months))
        default:
            break
        }

        let payment: Double
        if interestRate == 0 {
            payment = loanAmount / numberOfPeriods
        } else {
            let sub1 = interestPerPeriod * loanAmount
            let sub2 = 1 - pow(1 + interestPerPeriod, -numberOfPeriods)
            payment = sub1 / sub2
        }

        return PaymentResult(
            payment: payment,
            totalPayment: payment * numberOfPeriods,
            numberOfPeriods: numberOfPeriods,
            interestPerPeriod: interestPerPeriod
        )
    }

    static func generateAmortizationSchedule(
        loanAmount: Double,
        years: Int,
        months: Int,
        interestRate: Double,
        frequencyIndex: Int
    ) -> [Amortization] {
        
        let result = calculatePayment(
            loanAmount: loanAmount,
            years: years,
            months: months,
            interestRate: interestRate,
            frequencyIndex: frequencyIndex
        )
        
        let intPeriods = Int(result.numberOfPeriods.rounded(.down))
        var schedule: [Amortization] = []
        var balance = loanAmount
        
        if intPeriods >= 1 {
            for i in 1...intPeriods {
                let interest = balance * result.interestPerPeriod
                let principal = result.payment - interest
                balance -= principal
                schedule.append(Amortization(number: i, principal: principal, interest: interest, balance: balance))
            }
            
            if result.numberOfPeriods != Double(intPeriods) {
                let interest = balance * result.interestPerPeriod
                let principal = balance
                balance = 0
                schedule.append(Amortization(number: intPeriods + 1, principal: principal, interest: interest, balance: balance))
            } else {
                schedule[schedule.count - 1].balance = 0
            }
        }
        
        return schedule
    }
    
    static func calculateFullSchedule(
        loanAmount: Double,
        years: Int,
        months: Int,
        interestRate: Double,
        frequencyIndex: Int
    ) -> (result: PaymentResult, schedule: [Amortization]) {
        let result = calculatePayment(
            loanAmount: loanAmount,
            years: years,
            months: months,
            interestRate: interestRate,
            frequencyIndex: frequencyIndex
        )
        
        let schedule = generateAmortizationSchedule(
            loanAmount: loanAmount,
            years: years,
            months: months,
            interestRate: interestRate,
            frequencyIndex: frequencyIndex
        )
        
        return (result, schedule)
    }
}
