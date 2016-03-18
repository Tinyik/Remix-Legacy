//
//  WithdrawalRecordViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/10/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class WithdrawalRecordViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var records: [AVObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        self.title = "提现记录"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "联系客服", style: .Plain, target: self, action: "contactRemixService")
        self.tableView.separatorStyle = .None
        self.tableView.tableFooterView = UIView()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
 
    }
    
    func contactRemixService() {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://18149770476")!)
    }
    
    func fetchCloudData() {
        records = []
        let query = AVQuery(className: "WithdrawalRequest")
        query.whereKey("Submitter", equalTo: AVUser(withoutDataWithObjectId: CURRENT_USER.objectId))
        query.findObjectsInBackgroundWithBlock { (records, error) -> Void in
            if error == nil {
           
                for record in records {
                 
                    self.records.append(record as! AVObject)
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
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(17)]
        return NSAttributedString(string: "你还没有发起过提现申请。\n", attributes: attrDic)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        return NSAttributedString(string: "活动结束后，你可以将活动报名费提取到指定的支付宝或银行账户。你可以:", attributes: attrDic)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: FlatRed()]
        return NSAttributedString(string: "发起活动", attributes: attrDic)
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return false
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(red: 0.97255, green: 0.97255, blue: 0.97255, alpha: 1)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "NoData")
    }

    
    
    func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
        let subm = ActivitySubmissionViewController()
        let navi = RMNavigationController(rootViewController: subm)
        self.presentViewController(navi, animated: true, completion: nil)
        
    }

}
