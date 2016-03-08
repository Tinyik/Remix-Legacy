//
//  WithdrawInputViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/9/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class WithdrawInputViewController: UIViewController {

    @IBOutlet weak var inputField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .Plain, target: self, action: "submitWithdralRequest")
        // Do any additional setup after loading the view.
    }
    
    func submitWithdralRequest() {
        
    }
    
    @IBAction func backGroundTap(sender: UIControl) {
        inputField.resignFirstResponder()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
