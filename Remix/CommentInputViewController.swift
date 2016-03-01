//
//  CommentInputViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/1/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class CommentInputViewController: UIViewController, UITextViewDelegate {

    var presentingActivity: BmobObject!
    var currentUser = BmobUser.getCurrentUser()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = presentingActivity.objectForKey("Title") as? String
        inputTextView.delegate = self
        // Do any additional setup after loading the view.
    }

    @IBAction func addComment() {
        let newComment = BmobObject(className: "Comments")
        newComment.setObject(presentingActivity.objectId, forKey: "ParentActivityObjectId")
        newComment.setObject(currentUser.objectId, forKey: "UserObjectId")
        newComment.setObject(inputTextView.text, forKey: "Content")
        newComment.setObject(true, forKey: "isVisibleToUsers")
        newComment.saveInBackgroundWithResultBlock { (isSuccessful, error) -> Void in
            if isSuccessful {
                let alert = UIAlertController(title: nil, message: "评论添加成功", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: nil, message: "评论添加失败", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好吧", style: .Default, handler: { (action) -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)

            }
        }
        
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
            textView.text = ""
            textView.textColor = .blackColor()
        
        return true
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
   
}
