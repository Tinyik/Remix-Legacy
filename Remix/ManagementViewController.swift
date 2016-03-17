//
//  ManagementViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class ManagementViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var coverImgURLs: [NSURL]! = []
    var parentActivities: [AVObject] = []
    var selectedActivity: AVObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        let refreshCtrl = UIRefreshControl(frame: CGRectMake(0,0,40,40))
        refreshCtrl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.refreshControl = refreshCtrl
        self.title = "我发起的活动"
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .None
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提现记录", style: .Plain, target: self, action: "showWithdrawalRecord")
    }
    
    func refresh() {
        self.refreshControl?.beginRefreshing()
        fetchCloudData()
    }
    
    func showWithdrawalRecord() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("WithdrawalVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchCloudData() {
        coverImgURLs = []
        parentActivities = []
        let query = AVQuery(className: "Activity")
        query.whereKey("Submitter", equalTo: CURRENT_USER.objectId)
        query.whereKey("isHeldBySubmitter", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (activities, error) -> Void in
            if error == nil {
                if self.refreshControl?.refreshing == true {
                    self.refreshControl?.endRefreshing()
                }
                for activity in activities {
                    self.parentActivities.append(activity as! AVObject)
                    self.coverImgURLs.append(NSURL(string: (activity.objectForKey("CoverImg") as! AVFile).url)!)
                
                }
                self.tableView.reloadData()
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return parentActivities.count
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "把你的活动推文\"阅读原文\"链接或网页URL设定为\"remix://\" + \"活动唯一标识码\", 读者在手机上点击后即可自动跳转至Remix活动页面进行报名。"
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 155
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuse") as! ActivityCell
        print("lkjllskdf")
        selectedActivity = parentActivities[indexPath.row]
        cell.themeImg.sd_setImageWithURL(coverImgURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        cell.titleLabel.text = (selectedActivity.objectForKey("Title") as? String)?.stringByReplacingOccurrencesOfString("主办方提交:", withString: "")
        cell.objectId = selectedActivity.objectId
        cell.parentViewController = self
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
        if selectedActivity.objectForKey("isVisibleToUsers") as! Bool == true && selectedActivity.objectForKey("UnderReview") as! Bool == false {
            cell.statusIndicator.text = "审核已通过"
            cell.activityStatus = "Visible"
            cell.actionButton.hidden = false
        }else if selectedActivity.objectForKey("isVisibleToUsers") as! Bool == false && selectedActivity.objectForKey("UnderReview") as! Bool == true{
            cell.statusIndicator.text = "审核中"
            cell.actionButton.hidden = true
        }else if selectedActivity.objectForKey("isVisibleToUsers") as! Bool == false && selectedActivity.objectForKey("UnderReview") as! Bool == false{
            cell.statusIndicator.text = "活动已下架"
            cell.actionButton.hidden = false
            cell.activityStatus = "Invisible"
        }
        cell.orderNoLabel.text = "活动唯一标识码: " + selectedActivity.objectId
        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if parentActivities[indexPath.row].objectForKey("UnderReview") as! Bool == true {
            let alert = UIAlertController(title: "Remix提示", message: "╮(╯▽╰)╭活动仍在审核中，暂时无法查看报名情况与其他相关信息, 半小时后再来看看吧~", preferredStyle: .Alert)
            let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let candidateVC = storyBoard.instantiateViewControllerWithIdentifier("CandidateVC") as! CandidatesViewController
            candidateVC.objectId = parentActivities[indexPath.row].objectId
            candidateVC.coverImgURL = coverImgURLs[indexPath.row]
            candidateVC.parentActivity = parentActivities[indexPath.row]
            self.navigationController?.pushViewController(candidateVC, animated: true)
        }
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(17)]
        return NSAttributedString(string: "你还没有发起过活动。\n", attributes: attrDic)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        return NSAttributedString(string: "发起活动后，在这里你可以管理参与者并与他们取得联系。", attributes: attrDic)
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
        let navi = UINavigationController(rootViewController: subm)
        self.presentViewController(navi, animated: true, completion: nil)
        
    }

}
