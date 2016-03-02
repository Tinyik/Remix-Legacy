//
//  CommentsTableViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/1/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {

    weak var modalDelegate: ModalViewControllerDelegate?
    let currentUser = BmobUser.getCurrentUser()
    
    var presentingActivity: BmobObject!
    var parentActivityVC: RMActivityViewController!
    var activityComments: [BmobObject] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加评论", style: .Plain, target: self, action: "addNewComment")
        self.navigationController?.navigationBar.tintColor = .blackColor()
        
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
                let query = BmobQuery(className: "Comments")
        query.whereKey("ParentActivityObjectId", equalTo: presentingActivity.objectId)
        query.findObjectsInBackgroundWithBlock { (comments, error) -> Void in
            for comment in comments {
                self.activityComments.append(comment as! BmobObject)
            }
            self.tableView.reloadData()
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
            let navigationController = UINavigationController(rootViewController: settingsVC)
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
        let userId = activityComments[indexPath.row].objectForKey("UserObjectId") as! String
        let query = BmobQuery(className: "_User")
        query.getObjectInBackgroundWithId(userId) { (user, error) -> Void in
            if error == nil {
                cell.usernameLabel.text = (user as! BmobUser).username
                if let _avatar = user.objectForKey("Avatar") as? BmobFile {
                    let avatarURL = NSURL(string: _avatar.url)
                    cell.avatarView.sd_setImageWithURL(avatarURL, placeholderImage: UIImage(named: "DefaultAvatar"))
                }else{
                    cell.avatarView.image = UIImage(named: "DefaultAvatar")
                }
               
            }
        }
        return cell
    }
    
    
   
}
