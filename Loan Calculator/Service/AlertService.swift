//
//  AlertService.swift
//  HomeLoanCalculator
//
//  Created by Phan Nhat Dang on 11/27/19.
//  Copyright © 2019 Phan Nhat Dang. All rights reserved.
//

import Foundation
import UIKit

class AlertService {
    
    static func showInfoAlertAndComfirm(in vc: UIViewController, message:String, completion: @escaping (_ okOrRestore: Bool)->Void)  {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in
            completion(true)
        }
        
        let restore = UIAlertAction(title: "Restore", style: .default) { (_) in
            completion(false)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(restore)
        alert.addAction(ok)
        alert.addAction(cancel)
        vc.present(alert,animated: true )
    }
    
    static func showInfoAlert(in vc: UIViewController, title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(ok)
        vc.present(alert,animated: true )
    }
    
    //Save record
    static func saveRecord(in vc: UIViewController, completion: @escaping ( _ name:String ,_ isSuccess:Bool)->Void) {
        
        let alert = UIAlertController(title: "Save new", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (nameTF) in
            nameTF.autocapitalizationType = .sentences
            nameTF.placeholder = "Ex. New loan "
        }
        
        
        let add = UIAlertAction(title: "Save", style: .default) { (_) in
            guard let name = alert.textFields?.first?.text else {
                completion("",false)
                return
            }
            if  name == "" {
                completion("",false)
                return
            }
            
            completion(name,true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(add)
        alert.addAction(cancel)
        vc.present(alert,animated: true)
    }
    
    static func editRecordTitle(in vc: UIViewController, title:String, completion: @escaping ( _ title:String, _ isSuccess:Bool)->Void) {
        
        let alert = UIAlertController(title: StringForLocal.editName, message: nil, preferredStyle: .alert)
        
        alert.addTextField { (titleTF) in
            titleTF.autocapitalizationType = .sentences
            titleTF.text = title
        }
        
        
        let add = UIAlertAction(title: StringForLocal.edit, style: .default) { (_) in
            guard let title = alert.textFields?.first?.text else {
                completion("",false)
                return
            }
            if title == "" {
                completion("", false)
                return
            }
            
            completion(title,  true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        
        
        alert.addAction(add)
        alert.addAction(cancel)
        vc.present(alert,animated: true)
    }
    
    //MARK - Show done , deselect or select all
    static func showActionButton(in vc:UIViewController, completion: @escaping ( _ actionType: Int)->Void)  {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: StringForLocal.editName, style: .default , handler:{ (UIAlertAction)in
            completion(1)
        }))
        
        alert.addAction(UIAlertAction(title: StringForLocal.editPurchaseDate, style: .default , handler:{ (UIAlertAction)in
            completion(2)
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = vc.view
            popoverController.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        vc.present(alert, animated: true)
    }
    
    static func showPaymentFrequency(in vc:UIViewController, completion: @escaping ( _ actionType: Int)->Void)  {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: StringForLocal.daily, style: .default , handler:{ (UIAlertAction)in
            completion(0)
        }))
        
        alert.addAction(UIAlertAction(title: StringForLocal.weekly , style: .default , handler:{ (UIAlertAction)in
            completion(1)
        }))
        
        alert.addAction(UIAlertAction(title: StringForLocal.monthly , style: .default , handler:{ (UIAlertAction)in
            completion(2)
        }))
        
        alert.addAction(UIAlertAction(title: StringForLocal.quarterly, style: .default , handler:{ (UIAlertAction)in
            completion(3)
        }))
        alert.addAction(UIAlertAction(title: StringForLocal.semiannually , style: .default , handler:{ (UIAlertAction)in
            completion(4)
        }))
        alert.addAction(UIAlertAction(title: StringForLocal.annually , style: .default , handler:{ (UIAlertAction)in
            completion(5)
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = vc.view
            popoverController.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        vc.present(alert, animated: true)
    }
    
    static func addDecimalPlacesAlert(in vc: UIViewController,  completion: @escaping ( _ number:Int, _ isSuccess:Bool)->Void) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: StringForLocal.decimalPlaces, message: StringForLocal.decimalPlacesAlert, preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard let number = alert?.textFields![0].text  else {
                completion(-1,false)
                return
            }
            
            if Int(number) == nil  {
                completion(-1,false)
                return
            }
            
            let intNumber = Int(number)
            if intNumber! < 0 || intNumber! > 8 {
                completion(-1,false)
                return
            }
            completion(intNumber!,true)
        }))

        // 4. Present the alert.
        vc.present(alert, animated: true, completion: nil)
    }
   
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
