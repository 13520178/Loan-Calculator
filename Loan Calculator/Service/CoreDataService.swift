//
//  CoreDataService.swift
//  HomeLoanCalculator
//
//  Created by Phan Nhat Dang on 11/27/19.
//  Copyright © 2019 Phan Nhat Dang. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataService {
    static let shared = CoreDataService()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //MARK: USINGLIST Service
    func saveRecord(createdDate:String, loanAmount:Double, years:Int, months:Int, interestRate:Double, payment:Double,paymentFrequencyIndex:Int, name: String) -> Bool {
        
        let record = Record(context: context)
        record.createdDate = createdDate
        record.loanAmount = loanAmount
        record.years = Int16(years)
        record.months = Int16(months)
        record.interestRate = interestRate
        record.payment = payment
        record.paymentFrequencyIndex = Int16(paymentFrequencyIndex)
        record.extraPayment = 0.0
        record.name = name
        
        do {
            try context.save()
            print("Saving OK :)")
        }catch {
            print("Error saving context \(error)")
            return false
        }
        return true
    }
    
    func loadRecordArray() -> [Record] {
        var usingRecordArray = [Record]()
        let request: NSFetchRequest<Record> = Record.fetchRequest()
        do {
            usingRecordArray = try context.fetch(request)
        }catch {
            print("Error to fetching data from context \(error)")
        }
        
        return usingRecordArray
    }
    
    func saveAfterEditOrDelete() -> Bool {
        do {
            try context.save()
            print("Saving OK :)")
        }catch {
            print("Error saving after edit context \(error)")
            return false
        }
        return true
    }
    
    
    
}

