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
    var activityComments: [BmobObject] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加评论", style: .Plain, target: self, action: "addNewComment")
        self.navigationController?.navigationBar.tintColor = .blackColor()
        
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
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let commentInputVC = storyBoard.instantiateViewControllerWithIdentifier("CommentInputVC") as! CommentInputViewController
        commentInputVC.presentingActivity = self.presentingActivity
        self.navigationController?.pushViewController(commentInputVC, animated: true)
        
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
                let avatarURL = NSURL(string: (user.objectForKey("Avatar") as! BmobFile).url)
                cell.avatarView.sd_setImageWithURL(avatarURL, placeholderImage: UIImage(named: "SDPlaceholder"))
            }
        }
        return cell
    }
    
    
   
}
