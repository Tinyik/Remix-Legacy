//
//  CandidateDetailViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import MessageUI
import TTGSnackbar

class CandidateDetailViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    
    var customer: BmobUser!
    var order: BmobObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = customer.objectForKey("LegalName") as! String
        let press = UITapGestureRecognizer(target: self, action: "copyInfo:")
        self.tableView.addGestureRecognizer(press)
        setUpParallaxHeaderView()
    }

    func setUpParallaxHeaderView() {
        let headerView = UIView.loadFromNibNamed("UserHeaderView") as! UserHeaderView
        headerView.user = customer
        headerView.fetchUserInfo()
        let _headerView = ParallaxHeaderView.parallaxHeaderViewWithSubView(headerView) as! ParallaxHeaderView
        self.tableView.tableHeaderView = _headerView

    }
    
    func copyInfo(press: UITapGestureRecognizer) {
        let indexPath = self.tableView.indexPathForRowAtPoint(press.locationInView(self.tableView))
        if indexPath != nil {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! InfoCell
             UIPasteboard.generalPasteboard().string = cell.detailLabel.text
            let snackbar = TTGSnackbar.init(message: cell.titleLabel.text! + "已复制到剪贴板", duration: .Middle)
            snackbar.backgroundColor = FlatBlueDark()
            snackbar.show()
            
        }
        
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

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 60
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var lastSection = 1
        if let remark = order.objectForKey("Remarks") as? String {
            lastSection = 2
        }
        if section == lastSection {
            return 100
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var lastSection = 1
        if let remark = order.objectForKey("Remarks") as? String {
            lastSection = 2
        }
        
        if section == lastSection {
            let footerView = UIView.loadFromNibNamed("UserFooterView") as! UserFooterView
            footerView.dialPhoneButton.addTarget(self, action: "dialPhone", forControlEvents: .TouchUpInside)
            footerView.sendMessageButton.addTarget(self, action: "sendMessage", forControlEvents: .TouchUpInside)
            return footerView
        }

        return nil
    }
    

    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let remark = order.objectForKey("Remarks") as? String {
            print("sdfsdfsss")
            print(remark)
            return 3
        }
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            return 2
        }
        if section == 2 {
            return 1
        }
        return 4
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "报名者基本信息。点击下列信息可复制到剪贴板。"
        }
        if section == 1 {
            return "报名者附加信息。点击下列信息可复制到剪贴板。"
        }
        if section == 2 {
            return "报名表备注"
        }
        return nil
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! InfoCell
        cell.detailLabel.textColor = FlatRed()
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: cell.titleLabel.text = "姓名"
            cell.detailLabel.text = customer.objectForKey("LegalName") as? String
            case 1: cell.titleLabel.text = "学校或单位"
            cell.detailLabel.text = customer.objectForKey("School") as? String
            case 2: cell.titleLabel.text = "手机号"
            cell.detailLabel.text = customer.mobilePhoneNumber
            case 3: cell.titleLabel.text = "邮箱"
            cell.detailLabel.text = customer.email
            default: break
            }

        }
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0 : cell.titleLabel.text = "微博"
            if let weibo = customer.objectForKey("Weibo") as? String {
                cell.detailLabel.text = weibo
            }else{
                cell.detailLabel.text = "未填写"
            }
            case 1 : cell.titleLabel.text = "微信"
            if let weibo = customer.objectForKey("Wechat") as? String {
                cell.detailLabel.text = weibo
            }else{
                cell.detailLabel.text = "未填写"
                }
            default: break
            }
            
        }
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0: cell.titleLabel.text = "备注"
                    cell.detailLabel.textColor = FlatGray()
                    cell.detailLabel.text = order.objectForKey("Remarks") as! String
                
            default: break
            }
        }
        return cell
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func dialPhone() {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + customer.mobilePhoneNumber)!)
    }
    
    func sendMessage() {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.recipients = [customer.mobilePhoneNumber]
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
