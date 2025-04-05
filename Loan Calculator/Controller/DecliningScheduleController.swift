//
//  DecliningScheduleController.swift
//  Loan Calculator
//
//  Created by Đăng Phan on 4/4/25.
//  Copyright © 2025 Phan Đăng. All rights reserved.
//

import UIKit

class DecliningScheduleController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var principalPerPeriodLabel: UILabel!
    var schedule: [ReducingBalanceRepaymentSchedule] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let principalPerPeriod = schedule.first?.principal ?? 0
        principalPerPeriodLabel.text = "\(StringForLocal.principalPerPeriod): \(Tools.changeToCurrency(moneyStr: principalPerPeriod) ?? "")"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = schedule[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "decliningScheduleCell", for: indexPath) as! DecliningScheduleCell
        
        let numberForRound = pow(10.0, Double(UserDefaults.standard.integer(forKey: "decimalPlaces")))
        
        let payment = (row.totalPayment * numberForRound).rounded() / numberForRound
        let interest = (row.interest * numberForRound).rounded() / numberForRound
        let balance = (row.remainingPrincipal * numberForRound).rounded() / numberForRound
        
        cell.numberLabel.text = "\(row.period)"
        cell.paymentLabel.text = Tools.changeToCurrency(moneyStr: payment)
        cell.interestLabel.text = Tools.changeToCurrency(moneyStr: interest)
        cell.balanceLabel.text = Tools.changeToCurrency(moneyStr: balance)
        
        return cell
    }
    
}
