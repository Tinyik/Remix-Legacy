//
//  RemixPassViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/12/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class RemixPassViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "REMIX PASS"
        setUpParallaxHeaderView()
    }

    func setUpParallaxHeaderView() {
        let headerView = UIView.loadFromNibNamed("RemixPassView") as! RemixPassView
        headerView.user = CURRENT_USER
        headerView.fetchUserInfo()
        self.tableView.tableFooterView = UIView()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        let _headerView = ParallaxHeaderView.parallaxHeaderViewWithSubView(headerView) as! ParallaxHeaderView
        self.tableView.tableHeaderView = _headerView
        
        _headerView.layoutHeaderViewForScrollViewOffset(tableView.contentOffset)
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! CreditCell
        return cell
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(17)]
        return NSAttributedString(string: "\n\n\n\n\n\n\n\n\n\n\n\n你的REMIX PASS还没有任何积分记录。   (・_・ヾ\n", attributes: attrDic)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        return NSAttributedString(string: "在Remix报名参加活动或提交活动、地点获得通过后即可得到积分奖励。", attributes: attrDic)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: FlatRed()]
        return NSAttributedString(string: "了解详细积分规则和奖励", attributes: attrDic)
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }


}
