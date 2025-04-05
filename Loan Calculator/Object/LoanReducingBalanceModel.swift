//
//  LoanReducingBalanceModel.swift
//  DuNoGiamDan
//
//  Created by Đăng Phan on 23/3/25.
//

import Foundation

enum RepaymentFrequency {
    case daily, weekly, monthly, quarterly, semiAnnually, annually

    var periodsPerYear: Double {
        switch self {
        case .daily: return 365
        case .weekly: return 52
        case .monthly: return 12
        case .quarterly: return 4
        case .semiAnnually: return 2
        case .annually: return 1
        }
    }

    var monthsPerPeriod: Int {
        switch self {
        case .monthly: return 1
        case .quarterly: return 3
        case .semiAnnually: return 6
        case .annually: return 12
        default: return 0
        }
    }

    var advanceStep: (Calendar.Component, Int) {
        switch self {
        case .daily: return (.day, 1)
        case .weekly: return (.day, 7)
        case .monthly: return (.month, 1)
        case .quarterly: return (.month, 3)
        case .semiAnnually: return (.month, 6)
        case .annually: return (.month, 12)
        }
    }
}

/// Chi tiết một kỳ trả nợ theo dư nợ giảm dần
struct ReducingBalanceRepaymentSchedule {
    let period: Int
    let principal: Double
    let interest: Double
    let totalPayment: Double
    let remainingPrincipal: Double
    let dueDate: Date
}

class LoanReducingBalanceCalculator {

    let originalLoanAmount: Double
    let annualInterestRate: Double
    let loanDurationInMonths: Int
    let repaymentFrequency: RepaymentFrequency
    let startDate: Date
    let prepaymentAmount: Double

    init(loanAmount: Double,
         annualInterestRate: Double,
         loanDurationInMonths: Int,
         repaymentFrequency: RepaymentFrequency,
         startDate: Date,
         prepaymentAmount: Double = 0.0) {

        self.originalLoanAmount = loanAmount
        self.annualInterestRate = annualInterestRate
        self.loanDurationInMonths = loanDurationInMonths
        self.repaymentFrequency = repaymentFrequency
        self.startDate = startDate
        self.prepaymentAmount = prepaymentAmount
    }

    func calculateSchedule() -> [ReducingBalanceRepaymentSchedule] {
        let calendar = Calendar.current
        let effectiveLoanAmount = max(originalLoanAmount - prepaymentAmount, 0)
        let periodsPerYear = repaymentFrequency.periodsPerYear
        let interestRatePerPeriod = annualInterestRate / periodsPerYear / 100

        let (advanceUnit, advanceValue) = repaymentFrequency.advanceStep

        let numberOfPeriods: Int
        switch repaymentFrequency {
        case .daily:
            numberOfPeriods = Int(Double(loanDurationInMonths) / 12.0 * 365)
        case .weekly:
            numberOfPeriods = Int(Double(loanDurationInMonths) / 12.0 * 52)
        default:
            numberOfPeriods = loanDurationInMonths / repaymentFrequency.monthsPerPeriod
        }

        let principalPerPeriod = effectiveLoanAmount / Double(numberOfPeriods)

        var result: [ReducingBalanceRepaymentSchedule] = []
        var remaining = effectiveLoanAmount
        var dueDate = startDate

        for period in 1...numberOfPeriods {
            let interest = remaining * interestRatePerPeriod
            let total = principalPerPeriod + interest
            remaining -= principalPerPeriod

            result.append(
                ReducingBalanceRepaymentSchedule(
                    period: period,
                    principal: principalPerPeriod,
                    interest: interest,
                    totalPayment: total,
                    remainingPrincipal: max(remaining, 0),
                    dueDate: dueDate
                )
            )

            dueDate = calendar.date(byAdding: advanceUnit, value: advanceValue, to: dueDate) ?? dueDate
        }

        return result
    }
}
