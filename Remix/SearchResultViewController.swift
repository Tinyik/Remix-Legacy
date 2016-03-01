//
//  SearchResultViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices
import SDWebImage


class SearchResultViewController: UITableViewController, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, MGSwipeTableCellDelegate, BmobPayDelegate {
    
    var labelName = ""
    var delegate: ActivityFilterDelegate!
    
    var labelImageURLs: [NSURL] = []
    var labelImageURL: NSURL!
    var labelNames: [String] = []
    var activities: [BmobObject] = []
    var coverImgURLs: [NSURL] = []
    var likedActivitiesIds: [String] = []
    var currentUser = BmobUser.getCurrentUser()
    
    
    var ongoingTransactionId: String!
    var ongoingTransactionPrice: Double!
    var ongoingTransactionRemarks = "No comments."
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var trendingLabelsCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .None
        self.tableView.showsVerticalScrollIndicator = false
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
        self.title = "搜索"
       fetchTrendingLabels()
    }

    func popCurrentVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func fetchTrendingLabels() {
        let query = BmobQuery(className: "TrendingLabel")
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
        let query = BmobQuery(className: "Activity")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("isFloatingActivity", equalTo: false)
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
    
    
    func presentSettingsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsVC")
        let navigationController = UINavigationController(rootViewController: settingsVC)
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        
    }


    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if activities.count != 0 {
            self.tableView.separatorStyle = .SingleLine
        }else{
            self.tableView.separatorStyle = .None
        }
        return activities.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (activities[indexPath.row].objectForKey("isFeatured") as! Bool) == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("fullCellReuseIdentifier", forIndexPath: indexPath) as! RMFullCoverCell
            cell.delegate = self
            cell.parentViewController = self
            if let price = activities[indexPath.row].objectForKey("Price") as? Double {
                if price != 0 {
                    let priceNumberFont = UIFont.systemFontOfSize(19)
                    let attrDic1 = [NSFontAttributeName:priceNumberFont]
                    let priceString = NSMutableAttributedString(string: String(price), attributes: attrDic1)
                    let currencyFont = UIFont.systemFontOfSize(13)
                    let attrDic2 = [NSFontAttributeName:currencyFont]
                    let currencyString = NSMutableAttributedString(string: "元/人", attributes: attrDic2)
                    priceString.appendAttributedString(currencyString)
                    cell.priceTag.attributedText = priceString
                }else{
                    cell.priceTag.text = "免费"

                }
            }

            cell.titleLabel.text = activities[indexPath.row].objectForKey("Title") as? String
            cell.orgLabel.text = activities[indexPath.row].objectForKey("Org") as? String
            cell.timeLabel.text = activities[indexPath.row].objectForKey("Date") as? String
            cell.likesNumberLabel.text = String(activities[indexPath.row].objectForKey("LikesNumber") as! Int)
            cell.fullImageView.sd_setImageWithURL(coverImgURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
            let _objId = activities[indexPath.row].objectId
            cell.objectId = _objId
            let query = BmobQuery(className: "Organization")
            query.whereKey("Name", equalTo: cell.orgLabel.text)
            query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
                if error == nil {
                    for org in organizations {
                        let url = NSURL(string: (org.objectForKey("Logo") as! BmobFile).url)
                        cell.orgLogo.sd_setImageWithURL(url, placeholderImage: UIImage(named: "SDPlaceholder"))
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
        cell.parentViewController = self
        if let price = activities[indexPath.row].objectForKey("Price") as? Double {
            if price != 0 {
                let priceNumberFont = UIFont.systemFontOfSize(19)
                let attrDic1 = [NSFontAttributeName:priceNumberFont]
                let priceString = NSMutableAttributedString(string: String(price), attributes: attrDic1)
                let currencyFont = UIFont.systemFontOfSize(13)
                let attrDic2 = [NSFontAttributeName:currencyFont]
                let currencyString = NSMutableAttributedString(string: "元/人", attributes: attrDic2)
                priceString.appendAttributedString(currencyString)
                cell.priceTag.attributedText = priceString
                
            }else{
                cell.priceTag.text = "免费"
                
            }
        }

        cell.titleLabel.text = activities[indexPath.row].objectForKey("Title") as? String
        cell.desLabel.text = activities[indexPath.row].objectForKey("Description") as? String
        cell.orgLabel.text = activities[indexPath.row].objectForKey("Org") as? String
        cell.timeLabel.text = activities[indexPath.row].objectForKey("Date") as? String
        cell.likesNumberLabel.text = String(activities[indexPath.row].objectForKey("LikesNumber") as! Int)
        cell.themeImg.sd_setImageWithURL(coverImgURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        let _objId = activities[indexPath.row].objectId
        cell.objectId = _objId
        let query = BmobQuery(className: "Organization")
        query.whereKey("Name", equalTo: cell.orgLabel.text)
        query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
            if error == nil {
                for org in organizations {
                    let url = NSURL(string: (org.objectForKey("Logo") as! BmobFile).url)
                    cell.orgLogo.sd_setImageWithURL(url, placeholderImage: UIImage(named: "SDPlaceholder"))
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
    
 
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if activities.count > 0  {
            if let isFeatured = activities[indexPath.row].objectForKey("isFeatured") as? Bool  {
                if isFeatured == true {
                    return DEVICE_SCREEN_WIDTH
                }
            }
        }
        return DEVICE_SCREEN_WIDTH*0.4426
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
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = trendingLabelsCollectionView.dequeueReusableCellWithReuseIdentifier("reuseIdentifier", forIndexPath: indexPath) as! TrendingLabelCell
        cell.imageView.sd_setImageWithURL(labelImageURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        cell.nameLabel.text = labelNames[indexPath.row]
        
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        trendingLabelsCollectionView.deselectItemAtIndexPath(indexPath, animated: false)
        searchBar.resignFirstResponder()
        self.labelName = labelNames[indexPath.row]
        self.labelImageURL = labelImageURLs[indexPath.row]
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("showLabelFilteredVC", sender: nil)
        
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        searchBar.resignFirstResponder()
        if tableView == self.tableView {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            var query = BmobQuery(className: "Activity")
            let objectId = activities[indexPath.row].objectId
            query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
                activity.incrementKey("PageView", byAmount: 1)
                activity.updateInBackground()
            }
            let activityView = RMActivityViewController(url: NSURL(string: activities[indexPath.row].objectForKey("URL") as! String)!)
            activityView.activity = activities[indexPath.row]
            self.navigationController?.pushViewController(activityView, animated: true)

            
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
