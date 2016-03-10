//
//  PersonalInfoViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/26/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class PersonalInfoViewController: UITableViewController {

    
    var delegate: SettingInputViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "账户设置"
       
    }
    
    override func viewWillAppear(animated: Bool) {
        print("WILLAPPEAR")
        self.tableView.reloadData()
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
        cell.editingPropertyKey = "LegalName"
        cell.placeHolder = "姓名"
        cell.explanationText = "姓名将被活动主办方用于进行签到与联络。"

        if let legalName = CURRENT_USER.objectForKey("LegalName") as? String {
            cell.detailLabel.text = legalName
            cell.currentValue = legalName
            if legalName == "" {
                cell.detailLabel.text = "必填"
            }
        }else{
            cell.detailLabel.text = "必填"
            }
        case 1: cell.titleLabel.text = "学校或单位"
                cell.editingPropertyKey = "School"
                cell.placeHolder = "学校或单位"
                cell.explanationText = "学校信息将被活动主办方用于统计参与者数据和进行资源配置。"
        if let school = CURRENT_USER.objectForKey("School") as? String {
            cell.detailLabel.text = school
            cell.currentValue = school
            if school == "" {
                cell.detailLabel.text = "必填"
            }
        }else{
            cell.detailLabel.text = "必填"
            }
        case 2: cell.titleLabel.text = "昵称"
        cell.editingPropertyKey = "username"
        cell.placeHolder = "Remix昵称"
        cell.explanationText = "昵称将是他人在活动评论中看到的名字。"

        if let userName = CURRENT_USER.objectForKey("username") as? String {
            cell.detailLabel.text = userName
            cell.currentValue = userName
            if userName == "" {
                cell.detailLabel.text = "必填"
            }
        }else{
            cell.detailLabel.text = "必填"
            }
        case 3: cell.titleLabel.text = "邮箱"
        cell.editingPropertyKey = "email"
        cell.placeHolder = "常用邮箱"
        cell.explanationText = "邮箱地址信息将被活动主办方用于联络与信息更新。"

        if let email = CURRENT_USER.objectForKey("email") as? String {
            cell.detailLabel.text = email
            cell.currentValue = email
            if email == "" {
                cell.detailLabel.text = "必填"
            }
        }else{
            cell.detailLabel.text = "必填"
            }
        default: break
        }
        }
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0: cell.titleLabel.text = "新浪微博"
            cell.editingPropertyKey = "Weibo"
            cell.placeHolder = "微博用户名"
            cell.explanationText = ""
            if let weibo = CURRENT_USER.objectForKey("Weibo") as? String {
                cell.detailLabel.text = weibo
                cell.currentValue = weibo
                if weibo == "" {
                    cell.detailLabel.text = "未设置"
                }
            }else{
                cell.detailLabel.text = "未设置"
                }
            case 1: cell.titleLabel.text = "微信"
            cell.editingPropertyKey = "Wechat"
            cell.placeHolder = "微信号"
            cell.explanationText = "微信号将被活动主办方用于联络。"
            if let wechat = CURRENT_USER.objectForKey("Wechat") as? String {
                cell.detailLabel.text = wechat
                cell.currentValue = wechat
                if wechat == "" {
                    cell.detailLabel.text = "建议填写"
                }
            }else{
                cell.detailLabel.text = "建议填写"
                }
            default: break
            }
        }
        
        if cell.detailLabel.text == "必填" || cell.detailLabel.text == "建议填写" {
            cell.detailLabel.textColor = FlatRed()
        }else{
            cell.detailLabel.textColor = FlatGray()
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
   
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowInputView", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowInputView" {
            if let inputView = segue.destinationViewController as? SettingsInputViewController {
                self.delegate = inputView
                self.delegate.setEditingPropertyKey((sender as! InfoCell).editingPropertyKey!)
                self.delegate.setExplanationLabelText((sender as! InfoCell).explanationText!)
                self.delegate.setInputFieldPlaceHolder((sender as! InfoCell).placeHolder!)
                self.delegate.setInputFieldText((sender as! InfoCell).currentValue)
            }
        }
    }
}
