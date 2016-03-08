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

class CandidatesViewController: UITableViewController, MFMailComposeViewControllerDelegate{
    
    var objectId: String = ""
    var coverImgURL: NSURL!
    var orders: [BmobObject] = []
    var customers: [BmobUser] = []
    var parentActivity: BmobObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "查看活动页面", style: .Plain, target: self, action: "showActivityPage")
        fetchCloudData()
        setUpParallaxHeaderView()
        
    }
    
    func showActivityPage() {
        
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
