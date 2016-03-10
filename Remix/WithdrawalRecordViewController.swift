//
//  WithdrawalRecordViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/10/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class WithdrawalRecordViewController: UITableViewController {
    
    var records: [BmobObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        self.tableView.separatorStyle = .None
        
 
    }
    
    func fetchCloudData() {
        records = []
        let query = BmobQuery(className: "WithdrawalRequest")
        query.whereKey("Submitter", equalTo: CURRENT_USER.objectId)
        query.findObjectsInBackgroundWithBlock { (records, error) -> Void in
            if error == nil {
           
                for record in records {
                 
                    self.records.append(record as! BmobObject)
                }
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return records.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! RecordCell
        cell.accountLabel.text = "目标账户:    " + (records[indexPath.row].objectForKey("TargetAccount") as! String)
        cell.recordIdLabel.text = "工单号:   " + records[indexPath.row].objectId
        if records[indexPath.row].objectForKey("isResponded") as! Bool == false{
            cell.statusLabel.text = "等待受理"
        }else{
            cell.statusLabel.text = "已转入目标账户"
        }
        let dateString = String(records[indexPath.row].createdAt)
        cell.dateLabel.text = dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[0]
        let numberFont = UIFont(name: "AvenirNext-UltraLight", size: 70)
        let attrDic1 = [NSFontAttributeName:numberFont!]
        let ordersString = NSMutableAttributedString(string: String(Int(records[indexPath.row].objectForKey("Amount") as! Double)), attributes: attrDic1)
        let unitFont = UIFont.systemFontOfSize(18)
        let attrDic2 = [NSFontAttributeName:unitFont]
        let unitString = NSMutableAttributedString(string: "元", attributes: attrDic2)
        ordersString.appendAttributedString(unitString)
        cell.amountLabel.attributedText = ordersString
        

        return cell
    }
    

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "到账时间约为1至2个工作日。如需更改目标账户，请在活动管理界面更改或联系客服。"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
