//
//  SearchResultViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SDWebImage
import MessageUI
import TTGSnackbar

class SearchResultViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, MGSwipeTableCellDelegate, MFMailComposeViewControllerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, RMActivityViewControllerDelegate {
    
    var labelName = ""
    var delegate: ActivityFilterDelegate!
    
    var labelImageURLs: [NSURL] = []
    var labelImageURL: NSURL!
    var labelNames: [String] = []
    var activities: [AVObject] = []
    var coverImgURLs: [NSURL] = []
    var likedActivitiesIds: [String] = []
    
    
    var ongoingTransactionId: String!
    var ongoingTransactionPrice: Double!
    var ongoingTransactionRemarks = "No comments."
    
    var indexPathForSelectedActivity: NSIndexPath!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var trendingLabelsCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .None
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.tableFooterView = UIView()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        searchBar.searchBarStyle = .Minimal
        searchBar.delegate = self
        trendingLabelsCollectionView.delegate = self
        trendingLabelsCollectionView.dataSource = self
        self.navigationController?.navigationBar.tintColor = .whiteColor()
        self.title = "搜索"
        self.tableView.registerNib(UINib(nibName: "MiddleCoverCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MiddleCoverCell")
        self.tableView.registerNib(UINib(nibName: "RMTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "RMTableViewCell")
       fetchTrendingLabels()
    }

    func popCurrentVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func fetchTrendingLabels() {
        let query = AVQuery(className: "TrendingLabel")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
        query.findObjectsInBackgroundWithBlock { (labels, error) -> Void in
            if error == nil {
                if labels.count > 0{
                    for label in labels {
                        let labelName = label.objectForKey("Label") as! String
                        
                        let labelFile = label.objectForKey("Image") as! AVFile
                        let labelImageURL = NSURL(string: labelFile.url)!
                        self.labelNames.append(labelName)
                        self.labelImageURLs.append(labelImageURL)
                        self.trendingLabelsCollectionView.reloadData()
                    }
                }
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
            
        }
    }
    
   

    
    func fetchSearchResults() {
        activities = []
        coverImgURLs = []
        let query = AVQuery(className: "Activity")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("isFloatingActivity", equalTo: false)
        query.findObjectsInBackgroundWithBlock { (activities, error) -> Void in
            if error == nil{
                if activities.count > 0 {
                    for activity in activities {
                        let coverImg = activity.objectForKey("CoverImg") as! AVFile
                        let imageURL = NSURL(string:coverImg.url)!
                        
                        let org = activity.objectForKey("Org") as! String
                        let title = activity.objectForKey("Title") as! String
                        let description = activity.objectForKey("Description") as! String
                        
                        if org.rangeOfString(self.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil || title.rangeOfString(self.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil || description.rangeOfString(self.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil  {
                            self.activities.append(activity as! AVObject)
                            self.coverImgURLs.append(imageURL)
                        }
                        
                    }
                }
                
                self.tableView.reloadData()
                self.tableView.reloadEmptyDataSet()
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
           
        }
        
       fetchLikedActivitiesList()

        
    }
    
    func fetchLikedActivitiesList() {
        if let _likedlist = CURRENT_USER.objectForKey("LikedActivities") as? [String] {
            likedActivitiesIds = _likedlist
        }
    }
    // MARK: - Table view data source
    
    
    func presentSettingsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsVC")
        let navigationController = RMNavigationController(rootViewController: settingsVC)
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
            let cell = tableView.dequeueReusableCellWithIdentifier("MiddleCoverCell", forIndexPath: indexPath) as! RMFullCoverCell
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
            if let summary = activities[indexPath.row].objectForKey("Summary") as? String{
                cell.orgLabel.text = cell.orgLabel.text! + summary
            }
            let query = AVQuery(className: "Organization")
            query.whereKey("Name", equalTo: activities[indexPath.row].objectForKey("Org") as? String)
            query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
                if error == nil {
                    for org in organizations {
                        let url = NSURL(string: (org.objectForKey("Logo") as! AVFile).url)
                        cell.orgLogo.sd_setImageWithURL(url, placeholderImage: UIImage(named: "SDPlaceholder"))
                    }
                }else{
                    let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                    snackBar.backgroundColor = FlatWatermelonDark()
                    snackBar.show()
                }

            })
            if likedActivitiesIds.contains(_objId) {
                cell.isLiked = true
            }else{
                cell.isLiked = false
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RMTableViewCell", forIndexPath: indexPath) as! RMTableViewCell
        if let summary = activities[indexPath.row].objectForKey("Summary") as? String {
            cell.summaryLabel.text = summary
        }else{
            cell.summaryLabel.text = ""
        }

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
        let query = AVQuery(className: "Organization")
        query.whereKey("Name", equalTo: cell.orgLabel.text)
        query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
            if error == nil {
                for org in organizations {
                    let url = NSURL(string: (org.objectForKey("Logo") as! AVFile).url)
                    cell.orgLogo.sd_setImageWithURL(url, placeholderImage: UIImage(named: "SDPlaceholder"))
                }
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }

        })
        if likedActivitiesIds.contains(_objId) {
            cell.isLiked = true
        }else{
            cell.isLiked = false
        }
        return cell

    }
    
    func reloadRowForActivity(activity: AVObject, isFloating: Bool) {
        fetchLikedActivitiesList()
        if isFloating == false {
            let query = AVQuery(className: "Activity")
            query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
            query.getObjectInBackgroundWithId(activity.objectId) { (activity, error) -> Void in
                if error == nil {
                    self.activities[self.indexPathForSelectedActivity.row] = activity
                    self.tableView.reloadRowsAtIndexPaths([self.indexPathForSelectedActivity], withRowAnimation: .Automatic)
                }else{
                    let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                    snackBar.backgroundColor = FlatWatermelonDark()
                    snackBar.show()
                }
                
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if activities.count > 0  {
            if let isFeatured = activities[indexPath.row].objectForKey("isFeatured") as? Bool  {
                if isFeatured == true {
                    return 335
                }
            }
        }
        return 166
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
            var query = AVQuery(className: "Activity")
            query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
            let objectId = activities[indexPath.row].objectId
            query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
                if error == nil {
                    activity.incrementKey("PageView", byAmount: 1)
                    activity.saveInBackground()
                }else{
                    let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                    snackBar.backgroundColor = FlatWatermelonDark()
                    snackBar.show()
                }

            }
            let activityView = RMActivityViewController(url: NSURL(string: activities[indexPath.row].objectForKey("URL") as! String)!)
            activityView.activity = activities[indexPath.row]
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RMFullCoverCell {
                activityView.isLiked = cell.isLiked
            }
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RMTableViewCell {
                activityView.isLiked = cell.isLiked
            }
            indexPathForSelectedActivity = indexPath
            activityView.delegate = self
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
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(17)]
        return NSAttributedString(string: "嗯...搜索似乎没有返回结果。\n", attributes: attrDic)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        return NSAttributedString(string: "Remix团队会积极添加更多的活动和种类。当然，你也可以:", attributes: attrDic)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: FlatRed()]
        return NSAttributedString(string: "向Remix提交活动", attributes: attrDic)
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
       (self.navigationController as! RMSwipeBetweenViewControllers).recommendActivityAndLocation()
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
   }
