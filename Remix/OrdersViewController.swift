//
//  OrdersViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/28/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import TTGSnackbar

class OrdersViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var coverImgURLs: [NSURL]!
    var parentActivityIds: [String]!
    var parentActivities: [AVObject]!
    var selectedActivity: AVObject!
    var selectedOrder: AVObject!
    var orders: [AVObject]!
    var contactNumber: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.tintColor = .blackColor()
        self.title = "我的订单"
        self.tableView.separatorStyle = .None
           }

    
    func popCurrentVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.translucent = false
    }
    
    func fetchCloudData() {
        parentActivities = []
        parentActivityIds = []
        orders = []
        coverImgURLs = []
        
        let query = AVQuery(className: "Orders")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("CustomerObjectId", equalTo: AVUser(outDataWithObjectId: CURRENT_USER.objectId))
        query.findObjectsInBackgroundWithBlock { (orders, error) -> Void in
        
            if error == nil {
                for order in orders {
                    if let o = order.objectForKey("ParentActivityObjectId") as? AVObject {
                        self.parentActivityIds.append(o.objectId)
                    }
                    self.orders.append(order as! AVObject)
                    
                }
                
                self.findParentActivities()
            }
        }
    }
    
    func findParentActivities() {
        let query = AVQuery(className: "Activity")
        // Both visible and invisible activities should be processed.
        query.findObjectsInBackgroundWithBlock { (activities, error) -> Void in
            if error == nil {
               
                for activity in activities {
                    
                    if self.parentActivityIds.contains(activity.objectId) {
                        self.coverImgURLs.append(NSURL(string: (activity.objectForKey("CoverImg") as! AVFile).url)!)
                        self.parentActivities.append(activity as! AVObject)
                        
                    }else{
                        
                    }
                }
                
             self.tableView.reloadData()
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
            
        }
    }
    
    func removeOrderFromApplication() {
        let alert = UIAlertController(title: nil, message: "确认要移除这份订单吗？你的订单记录将仍保留在云端。若要取消报名，请联系主办方。", preferredStyle: .Alert)
        let action = UIAlertAction(title: "确认", style: .Destructive) { (action) -> Void in
          self.selectedOrder.setObject(false, forKey: "isVisibleToUsers")
          self.selectedOrder.saveInBackground()
          self.fetchCloudData()
        }
        let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func contactOrganization() {
        contactNumber = selectedActivity.objectForKey("Contact") as? String
        let alert = UIAlertController(title: "Remix拨号确认", message: "确认拨打 " +  "  " + contactNumber + " ?", preferredStyle: .ActionSheet)
        let action = UIAlertAction(title: "确认", style: .Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + self.contactNumber)!)
        }
        let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 155
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       
        return parentActivities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! ActivityOrderCell
        selectedActivity = parentActivities[indexPath.row]
        selectedOrder = orders[indexPath.row]
        cell.themeImg.sd_setImageWithURL(coverImgURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        if let _itemName = selectedActivity.objectForKey("ItemName") as? String {
            cell.titleLabel.text = _itemName
        }else{
            cell.titleLabel.text = selectedActivity.objectForKey("Title") as? String
        }
        cell.timeLabel.text = selectedActivity.objectForKey("Date") as? String
        cell.orgLabel.text = selectedActivity.objectForKey("Org") as? String
        if let price = selectedActivity.objectForKey("Price") as? Double {
            if price != 0 {
                let priceNumberFont = UIFont.systemFontOfSize(19)
                let attrDic1 = [NSFontAttributeName:priceNumberFont]
                let priceString = NSMutableAttributedString(string: String(price), attributes: attrDic1)
                let currencyFont = UIFont.systemFontOfSize(13)
                let attrDic2 = [NSFontAttributeName:currencyFont]
                let currencyString = NSMutableAttributedString(string: "元", attributes: attrDic2)
                priceString.appendAttributedString(currencyString)
                cell.priceTag.attributedText = priceString
            }else{
                cell.priceTag.text = "免费"
                
            }
        }
        if selectedOrder.objectForKey("CheckIn") as! Bool == false {
            cell.orderNoLabel.text = "订单号: " + selectedOrder.objectId.substringFromIndex(selectedOrder.objectId.startIndex.advancedBy(17))
        }else{
            cell.orderNoLabel.textColor = FlatRed()
            cell.orderNoLabel.text = "已签到"
        }
        cell.contactButton.addTarget(self, action: "contactOrganization", forControlEvents: .TouchUpInside)
        cell.deleteButton.addTarget(self, action: "removeOrderFromApplication", forControlEvents: .TouchUpInside)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let query = AVQuery(className: "Activity")
        let objectId = parentActivities[indexPath.row].objectId
        query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
            if error == nil {
                activity.incrementKey("PageView", byAmount: 1)
                activity.saveInBackground()
 
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
            
        }
        
            let activityView = RMActivityViewController(url: NSURL(string: parentActivities[indexPath.row].objectForKey("URL") as! String)!)
            activityView.activity = parentActivities[indexPath.row]
            activityView.toolBar.registerButton.userInteractionEnabled = false
            activityView.toolBar.likeButton.hidden = true
            activityView.shouldApplyWhiteTint = false
            self.navigationController?.pushViewController(activityView, animated: true)
        }
    
    //DZNEmptyDataSet
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "到达活动现场后，扫描主办方活动二维码即可进行签到并获取相应积分奖励。"
        }
        
        return nil
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(19)]
        return NSAttributedString(string: "(:3[____] 你还没有进行中的订单\n", attributes: attrDic)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        return NSAttributedString(string: "报名成功后活动的订单将出现在这里", attributes: attrDic)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: FlatRed()]
        return NSAttributedString(string: "去逛逛", attributes: attrDic)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(red: 0.97255, green: 0.97255, blue: 0.97255, alpha: 1)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "NoData")
    }
    
    func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}
