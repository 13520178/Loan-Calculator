//
//  SavedController.swift
//  Loan Calculator
//
//  Created by Phan Đăng on 8/25/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit
import GoogleMobileAds


class SavedController: UIViewController, UITableViewDelegate, UITableViewDataSource,GADBannerViewDelegate,GADFullScreenContentDelegate {
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var bannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightFromInputToResultContraint: NSLayoutConstraint!
    @IBOutlet weak var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd?
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    var records = [Record]()
    var indexOfEditDateRow = 0
    var selectedRow:Int = 0
    let isFirstTimeKey = "hasOpenedSavedControllerBefore"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("OK")

        let isFirstTime = !defaults.bool(forKey: isFirstTimeKey)

        if isFirstTime {
            print("🔹 Lần đầu mở SavedController, không hiển thị quảng cáo.")
            defaults.set(true, forKey: isFirstTimeKey) // Đánh dấu đã mở
        } else {
            if !defaults.bool(forKey: "isRemoveAds") {
                bannerView.delegate = self
                //bannerView.adUnitID = "ca-app-pub-9626752563546060/8998880902"
                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Test
                bannerView.rootViewController = self
            }
        }

        
        tableView.delegate = self
        tableView.dataSource = self
        
        records = CoreDataService.shared.loadRecordArray()
        blurView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }
    
    @objc func reload() {
        let isFirstTime = !defaults.bool(forKey: isFirstTimeKey)
        if !isFirstTime && !defaults.bool(forKey: "isRemoveAds") {
            if defaults.bool(forKey: "startShowAds") {
                loadBannerAd()
                bannerView.load(GADRequest())
                createAndLoadInterstitial()
            }
        } else {
            bannerView.isHidden = true
            heightFromInputToResultContraint.constant = 0
        }
    }
    
    // BANNER MAKING
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            let isFirstTime = !self.defaults.bool(forKey: self.isFirstTimeKey)
            if !isFirstTime &&
                !self.defaults.bool(forKey: "isRemoveAds") &&
                self.defaults.bool(forKey: "startShowAds") {
                self.loadBannerAd()
                self.bannerView.load(GADRequest())
            }
        })
    }
    
    func loadBannerAd() {
        // Step 2 - Determine the view width to use for the ad width.
        let frame = { () -> CGRect in
            // Here safe area is taken into account, hence the view frame is used
            // after the view has been laid out.
            if #available(iOS 11.0, *) {
                return view.frame.inset(by: view.safeAreaInsets)
            } else {
                return view.frame
            }
        }()
        let viewWidth = frame.size.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        bannerHeightConstraint.constant = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth).size.height
        print( bannerHeightConstraint.constant )
    }
    
    
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        if !self.defaults.bool(forKey: "isRemoveAds"){
            UIView.animate(withDuration: 1, animations: {
                self.heightFromInputToResultContraint.constant = bannerView.frame.height + 8
                //self.heightFromInputToResultContraint.constant = 0
            })
        }
    }
    
    // INTERSTITIAL MAKING
    
    func createAndLoadInterstitial() {
        //"ca-app-pub-9626752563546060/4772054800"
        //"ca-app-pub-3940256099942544/4411468910"
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
                               request: request,
                               completionHandler: { (ad, error) in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                self.interstitial = ad
                                self.interstitial?.fullScreenContentDelegate = self
                               }
        )
    }
    
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if !defaults.bool(forKey: "isRemoveAds"){
            createAndLoadInterstitial()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        records = CoreDataService.shared.loadRecordArray()
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Saved Cell") as! SavedCell
        let record = records[indexPath.row]
        if record.paymentFrequencyIndex == 0 {
            cell.paymentFrequency.text = StringForLocal.daily
        }else if record.paymentFrequencyIndex == 1 {
            cell.paymentFrequency.text = StringForLocal.weekly
        }else if record.paymentFrequencyIndex == 2 {
            cell.paymentFrequency.text = StringForLocal.monthly
        }else if record.paymentFrequencyIndex == 3 {
            cell.paymentFrequency.text = StringForLocal.quarterly
        }else if record.paymentFrequencyIndex == 4 {
            cell.paymentFrequency.text = StringForLocal.semiannually
        }else if record.paymentFrequencyIndex == 5 {
            cell.paymentFrequency.text = StringForLocal.annually
        }
        
        cell.loanAmountLabel.text = "\(Tools.changeToCurrency(moneyStr: record.loanAmount)!)"
        cell.paymentLabel.text = "\(Tools.changeToCurrency(moneyStr: record.payment)!)"
        cell.interestRateLabel.text = "\(Tools.changeToCurrency(moneyStr: record.interestRate)!)%"
        
        cell.nameLabel.text = "\(record.name ?? "Unknown")"
        
        var year = ""
        var month = ""
        if record.years > 1 {
            year = StringForLocal.years
        }else {
            year = StringForLocal.year
        }
        
        if record.months > 1 {
            month = StringForLocal.months
        }else {
            month = StringForLocal.month
        }
        cell.loanTermLabel.text = "\(record.years) \(year) \(record.months) \(month)"
        cell.createdDateLabel.text = "\(record.createdDate!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: StringForLocal.edit) { (action, indexPath) in
            tableView.isEditing = false
            AlertService.showActionButton(in: self, completion: { (index) in
                if index == 1 {
                    //Edit name
                    self.records = CoreDataService.shared.loadRecordArray()
                    AlertService.editRecordTitle(in: self, title: self.records[indexPath.row].name!, completion: { (newName, isSuccess) in
                        if isSuccess {
                            self.records[indexPath.row].name = newName
                            if CoreDataService.shared.saveAfterEditOrDelete() {
                                self.records = CoreDataService.shared.loadRecordArray()
                                self.tableView.reloadData()
                            }else {
                                AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.anErrorOccurred)
                            }
                        }else {
                            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.pleaseDoNotLeaveTheNameBlank)
                        }
                    })
                }else {
                    self.blurView.isHidden = false
                    self.indexOfEditDateRow = indexPath.row
                }
            })
            
        }
        editAction.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        
        let deleteAction = UITableViewRowAction(style: .default, title: StringForLocal.delete) { (action, indexPath) in
            self.records = CoreDataService.shared.loadRecordArray()
            tableView.isEditing = false
            
            CoreDataService.shared.context.delete(self.records[indexPath.row])
            
            if CoreDataService.shared.saveAfterEditOrDelete() {
                self.records.remove(at: indexPath.row)
                tableView.reloadData()
                self.records = CoreDataService.shared.loadRecordArray()
                
            }else {
                AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.anErrorOccurred)
            }
            
            
        }
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.2862745098, blue: 0.2862745098, alpha: 1)
        
        
        return [deleteAction,editAction]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
    @IBAction func cancelDatePressed(_ sender: UIButton) {
        blurView.isHidden = true

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRow = indexPath.row
        
        if !self.defaults.bool(forKey: "isRemoveAds"){
            if let ad = self.interstitial {
              ad.present(fromRootViewController: self)
            } else {
              print("Ad wasn't ready")
            }
        }
        performSegue(withIdentifier: "showSaveCalculator", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSaveCalculator",
            let destinationVC = segue.destination as? DetailSavedController {
            destinationVC.selectedRow = selectedRow
        }
    }
    
    @IBAction func doneDatePressed(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = datePicker.date
        let nextMonth = Calendar.current.date(byAdding: .month, value: 0, to: date)
        let dateString = dateFormatter.string(from: nextMonth!)
        records = CoreDataService.shared.loadRecordArray()
        records[indexOfEditDateRow].createdDate = dateString
        
        blurView.isHidden = true
        
        if !CoreDataService.shared.saveAfterEditOrDelete() {
            AlertService.showInfoAlert(in: self, title: StringForLocal.error, message: StringForLocal.anErrorOccurred)
        }
        tableView.reloadData()
    }
}
