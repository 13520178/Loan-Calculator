//
//  Constant.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 8/31/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import Foundation

class Constant {
    static var INTERESTPERDAY = 36525.0
    static var INTERESTPERWEEK = 5200.0
    static var INTERESTPERMONTH = 1200.0
    static var INTERESTPERQUARTER = 400.0
    static var INTERESTPERSEMIANNUALLY = 200.0
    static var INTERESTPERYEAR = 100.0
    
    
    static var DAYSPERYEAR = 365.25
    static var DAYSPERMONTH = 365.25 / 12
    static var WEEKSPERYEAR = 52.0
    static var WEEKSPERMONTH = (365.25 / 12) / 7
    static var DAYSPERWEEK  = 7.0
    static var MONTHSPERYEAR  = 12.0
    static var QUARTERSPERYEAR  = 4.0
    static var MONTHSPERQUARTER = 3.0
    static var SEMIANNUALLYSPERYEAR = 2.0
    static var MONTHSPERSEMIANNUALLY = 6.0
}
