//
//  PersonalInfoViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/26/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class PersonalInfoViewController: UITableViewController, UIGestureRecognizerDelegate {
    var currentUser = BmobUser.getCurrentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIButton(frame: CGRectMake(0,0,30,30))
        backButton.setImage(UIImage(named: "back"), forState: .Normal)
        backButton.addTarget(self, action: "popCurrentVC", forControlEvents: .TouchUpInside)
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.translucent = false
        self.title = "账户设置"
       
    }
    
    func popCurrentVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 4
        }else {
            return 2
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! InfoCell
        if indexPath.section == 0 {
        switch indexPath.row {
        case 0: cell.titleLabel.text = "姓名"
        if let legalName = currentUser.objectForKey("LegalName") as? String {
            cell.detailLabel.text = legalName
        }else{
            cell.detailLabel.text = "必填"
            }
        case 1: cell.titleLabel.text = "学校或单位"
        if let school = currentUser.objectForKey("School") as? String {
            cell.detailLabel.text = school
        }else{
            cell.detailLabel.text = "必填"
            }
        case 2: cell.titleLabel.text = "昵称"
        if let userName = currentUser.objectForKey("username") as? String {
            cell.detailLabel.text = userName
        }else{
            cell.detailLabel.text = "必填"
            }
        case 3: cell.titleLabel.text = "邮箱"
        if let email = currentUser.objectForKey("email") as? String {
            cell.detailLabel.text = email
        }else{
            cell.detailLabel.text = "必填"
            }
        default: break
        }
        }
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0: cell.titleLabel.text = "新浪微博"
            if let weibo = currentUser.objectForKey("Weibo") as? String {
                cell.detailLabel.text = weibo
            }else{
                cell.detailLabel.text = "未设置"
                }
            case 1: cell.titleLabel.text = "微信"
            if let wechat = currentUser.objectForKey("Wechat") as? String {
                cell.detailLabel.text = wechat
            }else{
                cell.detailLabel.text = "建议填写"
                }
            default: break
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "    基本信息"
        }
        
        if section == 1 {
            return "    其他"
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "个人信息仅需填写一次。报名活动后Remix将把你的个人信息发送给活动主办方。我们将严格保护你的个人信息安全。"
        }
        
        return nil
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
