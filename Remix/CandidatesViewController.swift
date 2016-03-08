//
//  CandidatesViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import MessageUI
import SDWebImage

class CandidatesViewController: UITableViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    var objectId: String = ""
    var coverImgURL: NSURL!
    var orders: [BmobObject] = []
    var customers: [BmobUser] = []
    var parentActivity: BmobObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "实用工具", style: .Plain, target: self, action: "showUtilities")
        fetchCloudData()
        setUpParallaxHeaderView()
        
    }
    
    func showUtilities() {
        let sheet = LCActionSheet(title: nil, buttonTitles: ["群发Remix推送消息", "群发邮件", "群发短信", "导出报名信息为表格"], redButtonIndex: -1) { (buttonIndex) -> Void in
            if buttonIndex == 0 {
                
            }
            if buttonIndex == 1 {
                self.sendGroupEmails()
            }
            
            if buttonIndex == 2 {
                self.sendGroupMessages()
            }
            
            if buttonIndex == 3 {
                self.exportAsCSV()
            }
           
        }
        
        sheet.show()
    }
    
    func exportAsCSV() {
        var docPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let filePath = docPath.stringByAppendingString("Participants.csv")
        let writer = CHCSVWriter(forWritingToCSVFile: filePath)
        writer.writeField("sdfsdfsdf")
    }
    
    func sendGroupEmails() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            var recipients: [String] = []
            for customer in customers {
                recipients.append(customer.email)
            }
            controller.setToRecipients(recipients)
            controller.mailComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func sendGroupMessages() {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            var recipients: [String] = []
            for customer in customers {
                recipients.append(customer.mobilePhoneNumber)
            }
            controller.recipients = recipients
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchCloudData() {
        orders = []
        customers = []
        let query = BmobQuery(className: "Orders")
        query.whereKey("ParentActivityObjectId", equalTo: objectId)
        query.findObjectsInBackgroundWithBlock { (orders, error) -> Void in
            if error == nil {
                for order in orders {
                    print("ORDER")
                    self.orders.append(order as! BmobObject)
                    let query2 = BmobQuery(className: "_User")
                    query2.getObjectInBackgroundWithId(order.objectForKey("CustomerObjectId") as! String, block: { (user, error) -> Void in
                        print("USER")
                        if error == nil {
                            self.customers.append(user as! BmobUser)
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    
    func setUpParallaxHeaderView() {
        let headerView = UIView.loadFromNibNamed("ActivityHeaderView") as! ActivityHeaderView
        headerView.activity = parentActivity
        headerView.coverImgURL = coverImgURL
        headerView.fetchActivityInfo()
        let _headerView = ParallaxHeaderView.parallaxHeaderViewWithSubView(headerView) as! ParallaxHeaderView
        self.tableView.tableHeaderView = _headerView
        
    }

    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let header: ParallaxHeaderView = tableView.tableHeaderView as! ParallaxHeaderView
        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
        
        //        self.tableView.tableHeaderView = header
    }
    
    override func viewDidAppear(animated: Bool) {
        (tableView.tableHeaderView as! ParallaxHeaderView).refreshBlurViewForNewImage()
        super.viewDidAppear(animated)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "报名者一览"
        }
        return nil
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return customers.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! CandidateCell
        cell.nameLabel.text = customers[indexPath.row].objectForKey("LegalName") as? String
        cell.detailLabel.text = customers[indexPath.row].email
        let url = NSURL(string: (customers[indexPath.row].objectForKey("Avatar") as! BmobFile).url)
        cell.avatarView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "DefaultAvatar"))
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let detailVC = storyBoard.instantiateViewControllerWithIdentifier("CandidateDetailVC") as! CandidateDetailViewController
        detailVC.customer = customers[indexPath.row]
        detailVC.order = orders[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }

    
}
