//
//  AppDelegate.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 8/24/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import Firebase
import UserMessagingPlatform
import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.portrait
    var myOrientation: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()
        
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false
        
        let debugSettings = UMPDebugSettings()
        debugSettings.testDeviceIdentifiers = ["1161338A-D177-4CF1-A14C-E34E2E215ED0"]
        debugSettings.geography = UMPDebugGeography.EEA
        parameters.debugSettings = debugSettings
        
        // Request an update to the consent information.
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(
            with: parameters,
            completionHandler: { error in
                if error != nil {
                    // Handle the error.
                } else {
                    let formStatus = UMPConsentInformation.sharedInstance.formStatus
                    if formStatus == UMPFormStatus.available {
                        self.loadForm()
                    }else {
                        self.checkATTStatus()
                    }
                }
            })
        
        return true
    }
    
    func checkATTStatus() {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            
            switch status {
            case .authorized:
                // ATT đã được hiển thị và người dùng đã cho phép theo dõi
                print("ATT đã được hiển thị và được cho phép.")
                UserDefaults.standard.set(true, forKey: "startShowAds")
            case .denied:
                // ATT đã được hiển thị nhưng người dùng đã từ chối theo dõi
                print("ATT đã được hiển thị nhưng bị từ chối.")
                UserDefaults.standard.set(true, forKey: "startShowAds")
            case .notDetermined:
                // ATT chưa được hiển thị hoặc người dùng chưa quyết định
                print("ATT chưa được hiển thị hoặc người dùng chưa quyết định.")
            case .restricted:
                // ATT bị hạn chế, ví dụ như do các giới hạn về quyền riêng tư trong thiết bị
                print("ATT bị hạn chế.")
            @unknown default:
                // Trạng thái ATT không xác định
                break
            }
        } else {
            // Phiên bản iOS không hỗ trợ ATT (trước iOS 14)
            print("Phiên bản iOS không hỗ trợ ATT.")
        }
    }
    
    func loadForm() {
        UMPConsentForm.load(completionHandler: { form, loadError in
            if loadError != nil {
                // Xử lý lỗi.
            } else {
                // Hiển thị form. Bạn cũng có thể lưu tham chiếu để hiển thị sau.
                if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.required {
                    if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                        form?.present(from: rootViewController, completionHandler: { dismissError in
                            if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.obtained {
                                UserDefaults.standard.set(true, forKey: "startShowAds")
                            }
                            // Xử lý khi form bị đóng và tải lại form.
                            self.loadForm()
                        })
                    }
                } else {
                    // Giữ form để cho phép thay đổi sự đồng ý của người dùng.
                }
            }
        })
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return myOrientation
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Loan_Calculator")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

