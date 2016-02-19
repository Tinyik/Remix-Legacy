//
//  SearchResultViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices


class SearchResultViewController: UITableViewController, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, MGSwipeTableCellDelegate {
    
    var labelName = ""
    var delegate: ActivityFilterDelegate!
    
    var labelImageURLs: [NSURL] = []
    var labelImageURL: NSURL!
    var labelNames: [String] = []
    var activities: [BmobObject] = []
    var coverImgURLs: [NSURL] = []
    var likedActivitiesIds: [String] = []
    var currentUser = BmobUser.getCurrentUser()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var trendingLabelsCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.searchBarStyle = .Minimal
        searchBar.delegate = self
        trendingLabelsCollectionView.delegate = self
        trendingLabelsCollectionView.dataSource = self
        let backButton = UIButton(frame: CGRectMake(0,0,30,30))
        backButton.setImage(UIImage(named: "back"), forState: .Normal)
        backButton.addTarget(self, action: "popCurrentVC", forControlEvents: .TouchUpInside)
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.translucent = false
       fetchTrendingLabels()
    }

    func popCurrentVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func fetchTrendingLabels() {
        
        var query = BmobQuery(className: "TrendingLabel")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (labels, error) -> Void in
            if labels.count > 0{
                for label in labels {
                    let labelName = label.objectForKey("Label") as! String
               
                    let labelFile = label.objectForKey("Image") as! BmobFile
                    let labelImageURL = NSURL(string: labelFile.url)!
                    self.labelNames.append(labelName)
                    self.labelImageURLs.append(labelImageURL)
                    self.trendingLabelsCollectionView.reloadData()
                }
            }
        }
    }
    
    func fetchSearchResults() {
        activities = []
        coverImgURLs = []
        var query = BmobQuery(className: "Activity")
        query.findObjectsInBackgroundWithBlock { (activities, error) -> Void in
            if activities.count > 0 {
                for activity in activities {
                    let coverImg = activity.objectForKey("CoverImg") as! BmobFile
                    let imageURL = NSURL(string:coverImg.url)!

                    let org = activity.objectForKey("Org") as! String
                    let title = activity.objectForKey("Title") as! String
                    let description = activity.objectForKey("Description") as! String
                    
                    
                    if org.rangeOfString(self.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil || title.rangeOfString(self.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil || description.rangeOfString(self.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil  {
                        self.activities.append(activity as! BmobObject)
                        self.coverImgURLs.append(imageURL)
                    }
                    
                }
            }
            
            self.tableView.reloadData()
        }
        
        if let _likedlist = currentUser.objectForKey("LikedActivities") as? [String] {
            likedActivitiesIds = _likedlist
        }

        
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activities.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (activities[indexPath.row].objectForKey("isFeatured") as! Bool) == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("fullCellReuseIdentifier", forIndexPath: indexPath) as! RMFullCoverCell
            cell.delegate = self
            cell.titleLabel.text = activities[indexPath.row].objectForKey("Title") as! String
            cell.orgLabel.text = activities[indexPath.row].objectForKey("Org") as! String
            cell.timeLabel.text = activities[indexPath.row].objectForKey("Date") as! String
            cell.likesNumberLabel.text = String(activities[indexPath.row].objectForKey("LikesNumber") as! Int)
            cell.fullImageView.sd_setImageWithURL(coverImgURLs[indexPath.row])
            let _objId = activities[indexPath.row].objectId
            cell.objectId = _objId
            let query = BmobQuery(className: "Organization")
            query.whereKey("isVisibleToUsers", equalTo: true)
            query.whereKey("Name", equalTo: cell.orgLabel.text)
            query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
                if error == nil {
                    for org in organizations {
                        let url = NSURL(string: (org.objectForKey("Logo") as! BmobFile).url)
                        cell.orgLogo.sd_setImageWithURL(url)
                    }
                }
            })
            if likedActivitiesIds.contains(_objId) {
                cell.isLiked = true
            }else{
                cell.isLiked = false
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! RMTableViewCell
        cell.delegate = self
        cell.titleLabel.text = activities[indexPath.row].objectForKey("Title") as! String
        cell.desLabel.text = activities[indexPath.row].objectForKey("Description") as! String
        cell.orgLabel.text = activities[indexPath.row].objectForKey("Org") as! String
        cell.timeLabel.text = activities[indexPath.row].objectForKey("Date") as! String
        cell.likesNumberLabel.text = String(activities[indexPath.row].objectForKey("LikesNumber") as! Int)
        cell.themeImg.sd_setImageWithURL(coverImgURLs[indexPath.row])
        let _objId = activities[indexPath.row].objectId
        cell.objectId = _objId
        let query = BmobQuery(className: "Organization")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("Name", equalTo: cell.orgLabel.text)
        query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
            if error == nil {
                for org in organizations {
                    let url = NSURL(string: (org.objectForKey("Logo") as! BmobFile).url)
                    cell.orgLogo.sd_setImageWithURL(url)
                }
            }
        })
        if likedActivitiesIds.contains(_objId) {
            cell.isLiked = true
        }else{
            cell.isLiked = false
        }
        return cell

    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        
        swipeSettings.transition = .Border
        expansionSettings.fillOnTrigger = false
        expansionSettings.threshold = 1.5
        expansionSettings.buttonIndex = 1
        var likeButtonTitle: String!
        if let _cell = cell as? RMTableViewCell {
            likeButtonTitle = _cell.likeButtonTitle
        }
        if let _cell = cell as? RMFullCoverCell {
            likeButtonTitle = _cell.likeButtonTitle
        }
        
        if direction == .RightToLeft {
            
            let shareButton = MGSwipeButton(title: "Share", backgroundColor: UIColor(white: 0.95, alpha: 1), callback: { (sender) -> Bool in
                
                let indexPath = self.tableView.indexPathForCell(cell)
                let activity = self.activities[indexPath!.row]
                let coverImageURL = self.coverImgURLs[indexPath!.row]
                let shareText = "Remix活动推荐: " + (activity.objectForKey("Title") as! String)
                let manager = SDWebImageManager()
                manager.downloadImageWithURL(coverImageURL, options: .RetryFailed, progress: nil, completed: { (coverImage, error, cache, finished, url) -> Void in
                    if error == nil {
                        let url = activity.objectForKey("URL") as! String
                        let handler = UMSocialWechatHandler.setWXAppId("wx6e2c22b24588e0e1", appSecret: "e085edb726c5b92bf443f1e3da3f838e", url: url)
                        UMSocialSnsService.presentSnsIconSheetView(self, appKey: "56ba8fa2e0f55a1071000931", shareText: shareText, shareImage: coverImage, shareToSnsNames: [UMShareToWechatSession,UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone, UMShareToTwitter], delegate: nil)
                    }
                })
                
                return true
            })
            
            let likeButton = MGSwipeButton(title: likeButtonTitle, backgroundColor: UIColor(white: 0.9, alpha: 1), callback: { (sender) -> Bool in
                if let _cell = sender as? RMTableViewCell {
                    _cell.isLiked = !(sender as! RMTableViewCell).isLiked
                    if _cell.isLiked == true {
                        self.likedActivitiesIds.append(_cell.objectId)
                        _cell.likesNumberLabel.text = String(Int(_cell.likesNumberLabel.text!)! + 1)
                        let query = BmobQuery(className: "Activity")
                        query.getObjectInBackgroundWithId(_cell.objectId, block: { (activity, error) -> Void in
                            activity.incrementKey("LikesNumber", byAmount: 1)
                            activity.updateInBackground()
                        })
                        print(self.likedActivitiesIds)
                    }else{
                        if let index = self.likedActivitiesIds.indexOf(_cell.objectId) {
                            self.likedActivitiesIds.removeAtIndex(index)
                            _cell.likesNumberLabel.text = String(Int(_cell.likesNumberLabel.text!)! - 1)
                            let query = BmobQuery(className: "Activity")
                            query.getObjectInBackgroundWithId(_cell.objectId, block: { (activity, error) -> Void in
                                activity.decrementKey("LikesNumber", byAmount: 1)
                                activity.updateInBackground()
                            })
                            print(self.likedActivitiesIds)
                        }
                    }
                    self.currentUser.setObject(self.likedActivitiesIds, forKey: "LikedActivities")
                    self.currentUser.updateInBackground()
                    
                    
                }
                if let _cell = sender as? RMFullCoverCell {
                    _cell.isLiked = !(sender as! RMFullCoverCell).isLiked
                    if _cell.isLiked == true {
                        self.likedActivitiesIds.append(_cell.objectId)
                        _cell.likesNumberLabel.text = String(Int(_cell.likesNumberLabel.text!)! + 1)
                        let query = BmobQuery(className: "Activity")
                        query.getObjectInBackgroundWithId(_cell.objectId, block: { (activity, error) -> Void in
                            activity.incrementKey("LikesNumber", byAmount: 1)
                            activity.updateInBackground()
                        })
                        
                    }else{
                        if let index = self.likedActivitiesIds.indexOf(_cell.objectId) {
                            self.likedActivitiesIds.removeAtIndex(index)
                            _cell.likesNumberLabel.text = String(Int(_cell.likesNumberLabel.text!)! - 1)
                            let query = BmobQuery(className: "Activity")
                            query.getObjectInBackgroundWithId(_cell.objectId, block: { (activity, error) -> Void in
                                activity.decrementKey("LikesNumber", byAmount: 1)
                                activity.updateInBackground()
                            })
                            
                            
                        }
                    }
                    self.currentUser.setObject(self.likedActivitiesIds, forKey: "LikedActivities")
                    self.currentUser.updateInBackground()
                }
                if let _cell = cell as? RMTableViewCell {
                    cell.rightButtons[1].setTitle(_cell.likeButtonTitle, forState: .Normal)
                }
                if let _cell = cell as? RMFullCoverCell {
                    cell.rightButtons[1].setTitle(_cell.likeButtonTitle, forState: .Normal)
                }
                return true
            })
            shareButton.setTitleColor(.blackColor(), forState: .Normal)
            return [shareButton, likeButton] }else{
            return  nil
        }
        
        
    }
    

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if activities.count > indexPath.row  {
            if let isFeatured = activities[indexPath.row].objectForKey("isFeatured") as? Bool  {
                if isFeatured == true {
                    return 375
                }
            }
        }
        return 138
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    //    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    //         return UIEdgeInsetsMake(35, 20, 5, 20)
    //    }
    //
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(collectionView.frame.size.width/3, 140)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return labelNames.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = trendingLabelsCollectionView.dequeueReusableCellWithReuseIdentifier("reuseIdentifier", forIndexPath: indexPath) as! TrendingLabelCell
        cell.imageView.sd_setImageWithURL(labelImageURLs[indexPath.row])
        cell.nameLabel.text = labelNames[indexPath.row]
        
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        trendingLabelsCollectionView.deselectItemAtIndexPath(indexPath, animated: false)
        self.labelName = labelNames[indexPath.row]
        self.labelImageURL = labelImageURLs[indexPath.row]
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("showLabelFilteredVC", sender: nil)
        
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if tableView == self.tableView {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            var query = BmobQuery(className: "Activity")
            let objectId = activities[indexPath.row].objectId
            query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
                activity.incrementKey("PageView", byAmount: 1)
                activity.updateInBackground()
            }
            if #available(iOS 9.0, *) {
                let safariView = SFSafariViewController(URL: NSURL(string: activities[indexPath.row].objectForKey("URL") as! String)!, entersReaderIfAvailable: true)
                safariView.view.tintColor = UIColor(red: 74/255, green: 144/255, blue: 224/255, alpha: 1)
                self.navigationController?.presentViewController(safariView, animated: true, completion: nil)
            } else {
                let webView = RxWebViewController(url: NSURL(string: activities[indexPath.row].objectForKey("URL") as! String)!)
                self.navigationController?.pushViewController(webView, animated: true)
            }
            
        }
    }
    

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        fetchSearchResults()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showLabelFilteredVC" {
            if let fVC = segue.destinationViewController as? LabelFilteredViewController {
                
                self.delegate = fVC
                self.delegate.filterQueryWithCategoryOrLabelName(labelName)
                self.delegate.setParallaxHeaderImage(labelImageURL)
                
                
            }
        }
    }

}
