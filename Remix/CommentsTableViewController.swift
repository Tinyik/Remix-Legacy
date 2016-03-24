//
//  CommentsTableViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/1/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import TTGSnackbar
class CommentsTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    weak var modalDelegate: ModalViewControllerDelegate?
    
    var presentingActivity: AVObject!
    var parentActivityVC: RMActivityViewController!
    var activityComments: [AVObject] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加评论", style: .Plain, target: self, action: "addNewComment")
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = FlatRed()
        
        // Bottom margin for halved view
        let tableViewBottomMargin: CGFloat = DEVICE_SCREEN_HEIGHT - COMMENTS_TABLE_VIEW_VISIBLE_HEIGHT
        tableView.contentInset = UIEdgeInsetsMake(0, 0, tableViewBottomMargin, 0)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchCloudData()
    }
    
    func fetchCloudData() {
        activityComments = []
                let query = AVQuery(className: "Comments")
        query.whereKey("ParentActivityObjectId", equalTo:  AVObject(outDataWithClassName: "Activity", objectId: presentingActivity.objectId))
        query.findObjectsInBackgroundWithBlock { (comments, error) -> Void in
            if error == nil {
                for comment in comments {
                    self.activityComments.append(comment as! AVObject)
                }
                self.tableView.reloadData()
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
           
        }
    }
    
   
   
    func addNewComment() {
        if parentActivityVC.checkPersonalInfoIntegrity() {
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let commentInputVC = storyBoard.instantiateViewControllerWithIdentifier("CommentInputVC") as! CommentInputViewController
            commentInputVC.presentingActivity = self.presentingActivity
            self.navigationController?.pushViewController(commentInputVC, animated: true)

        }else{
            let alert = UIAlertController(title: "完善信息", message: "请先进入账户设置完善个人信息后再继续添加评论。", preferredStyle: .Alert)
            let action = UIAlertAction(title: "去设置", style: .Default, handler: { (action) -> Void in
                self.presentSettingsVC()
            })
            let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: nil)

        }
    }
    
    func presentSettingsVC() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsVC")
            let navigationController = RMNavigationController(rootViewController: settingsVC)
            self.parentActivityVC.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
        })
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activityComments.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! CommentCell
        cell.commentContentLabel.text = activityComments[indexPath.row].objectForKey("Content") as? String
        let dateString = String(activityComments[indexPath.row].createdAt)
        cell.timeLabel.text = dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[0]
        let userId = (activityComments[indexPath.row].objectForKey("UserObjectId") as! AVObject).objectId
        let query = AVQuery(className: "_User")
        query.getObjectInBackgroundWithId(userId) { (user, error) -> Void in
            if error == nil {
                cell.usernameLabel.textColor = FlatRed()
                cell.usernameLabel.text = (user as! AVUser).username
                if let _avatar = user.objectForKey("Avatar") as? AVFile {
                    let avatarURL = NSURL(string: _avatar.url)
                    cell.avatarView.sd_setImageWithURL(avatarURL, placeholderImage: UIImage(named: "DefaultAvatar"))
                }else{
                    cell.avatarView.image = UIImage(named: "DefaultAvatar")
                }
               
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
        }
        return cell
    }
    
    //DZNEmptyDataSet
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(19)]
        return NSAttributedString(string: "..._(:з」∠)_...\n", attributes: attrDic)
    }
    
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        return NSAttributedString(string: "这么精彩的活动，居然没人评论？😳", attributes: attrDic)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: FlatRed()]
        return NSAttributedString(string: ">>>抢占沙发<<<", attributes: attrDic)
    }
    
    
    func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
       self.addNewComment()
    }

   
}
