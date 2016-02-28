//
//  OrdersViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/28/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices

class OrdersViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var coverImgURLs: [NSURL]!
    var parentActivityIds: [String]!
    var parentActivities: [BmobObject]!
    var selectedActivity: BmobObject!
    var selectedOrder: BmobObject!
    var orders: [BmobObject]!
    var contactNumber: String!
    let currentUser = BmobUser.getCurrentUser()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        let backButton = UIButton(frame: CGRectMake(0,0,30,30))
        backButton.setImage(UIImage(named: "back"), forState: .Normal)
        backButton.addTarget(self, action: "popCurrentVC", forControlEvents: .TouchUpInside)
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.translucent = false
        self.title = "我的订单"
        self.tableView.separatorStyle = .None
           }

    
    func popCurrentVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchCloudData() {
        parentActivities = []
        parentActivityIds = []
        orders = []
        coverImgURLs = []
        
        let query = BmobQuery(className: "Orders")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("CustomerObjectId", equalTo: currentUser.objectId)
        query.findObjectsInBackgroundWithBlock { (orders, error) -> Void in
            if error == nil {
                for order in orders {
                    self.parentActivityIds.append(order.objectForKey("ParentActivityObjectId") as! String)
                    self.orders.append(order as! BmobObject)
                }
                
                self.findParentActivities()
            }
        }
    }
    
    func findParentActivities() {
        let query = BmobQuery(className: "Activity")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (activities, error) -> Void in
            if error == nil {
                for activity in activities {
                    print(activity.objectId)
                    if self.parentActivityIds.contains(activity.objectId) {
                        self.coverImgURLs.append(NSURL(string: (activity.objectForKey("CoverImg") as! BmobFile).url)!)
                        self.parentActivities.append(activity as! BmobObject)
                    }
                }
                print("READY")
                print(self.parentActivities.count)
             self.tableView.reloadData()
            }
            
        }
    }
    
    func removeOrderFromApplication() {
        let alert = UIAlertController(title: nil, message: "确认要移除这份订单吗？你的订单记录将仍保留在云端。若要取消报名，请联系主办方。", preferredStyle: .Alert)
        let action = UIAlertAction(title: "确认", style: .Destructive) { (action) -> Void in
          self.selectedOrder.setObject(false, forKey: "isVisibleToUsers")
          self.selectedOrder.updateInBackground()
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
        cell.orderNoLabel.text = "订单号: " + selectedOrder.objectId
        cell.contactButton.addTarget(self, action: "contactOrganization", forControlEvents: .TouchUpInside)
        cell.deleteButton.addTarget(self, action: "removeOrderFromApplication", forControlEvents: .TouchUpInside)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let query = BmobQuery(className: "Activity")
        let objectId = parentActivities[indexPath.row].objectId
        query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
            activity.incrementKey("PageView", byAmount: 1)
            activity.updateInBackground()
        }
        if #available(iOS 9.0, *) {
            let safariView = SFSafariViewController(URL: NSURL(string: parentActivities[indexPath.row].objectForKey("URL") as! String)!, entersReaderIfAvailable: false)
            safariView.view.tintColor = UIColor(red: 74/255, green: 144/255, blue: 224/255, alpha: 1)
            self.navigationController?.presentViewController(safariView, animated: true, completion: nil)
        } else {
            let webView = RxWebViewController(url: NSURL(string: parentActivities[indexPath.row].objectForKey("URL") as! String)!)
            self.navigationController?.pushViewController(webView, animated: true)
        }
        
    }

    
}
