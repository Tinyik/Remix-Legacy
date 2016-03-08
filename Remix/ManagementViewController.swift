//
//  ManagementViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class ManagementViewController: UITableViewController {
    
    var coverImgURLs: [NSURL]! = []
    var parentActivities: [BmobObject] = []
    var selectedActivity: BmobObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        
    }
    
    func fetchCloudData() {
        let query = BmobQuery(className: "Activity")
        query.whereKey("Submitter", equalTo: CURRENT_USER.objectId)
        query.findObjectsInBackgroundWithBlock { (activities, error) -> Void in
            if error == nil {
                for activity in activities {
                    self.parentActivities.append(activity as! BmobObject)
                    self.coverImgURLs.append(NSURL(string: (activity.objectForKey("CoverImg") as! BmobFile).url)!)
                
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 155
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuse") as! ActivityCell
        print("lkjllskdf")
        selectedActivity = parentActivities[indexPath.row]
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
        if selectedActivity.objectForKey("isVisibleToUsers") as! Bool == true {
            cell.statusIndicator.text = "审核已通过"
        }else{
            cell.statusIndicator.text = "审核中"
        }
        cell.orderNoLabel.text = "活动唯一识别码: " + selectedActivity.objectId
        return cell
    }

    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let candidateVC = storyBoard.instantiateViewControllerWithIdentifier("CandidateVC") as! CandidatesViewController
        candidateVC.objectId = parentActivities[indexPath.row].objectId
        self.navigationController?.pushViewController(candidateVC, animated: true)
    }

}
