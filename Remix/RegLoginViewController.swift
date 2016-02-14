//
//  RegLoginViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/9/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class RegLoginViewController: UIViewController, ModalTransitionDelegate, GHWalkThroughViewDataSource {

    var toolBar: UIToolbar!
    var phoneNumberField: UITextField!
    var captchaField: UITextField!
    var isCaptchaFieldPresenting = false
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    weak var modalDelegate: ModalViewControllerDelegate?
    
    var countDown = 60
    var timer: NSTimer!
    
    var  nextStepButton = UIButton(type: .System)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
       
        // Do any additional setup after loading the view.
    }
    
    func setUpViews() {
        let RMWalkThroughView = GHWalkThroughView(frame: self.view.bounds)
         RMWalkThroughView.dataSource = self
         RMWalkThroughView.walkThroughDirection = .Horizontal
         RMWalkThroughView.showInView(self.view, animateDuration: 0.3)
         toolBar = UIToolbar(frame: CGRectMake(0.0, self.view.bounds.size.height - 53.0, self.view.bounds.size.width, 112.0))
         let tbBG = UIImage(named: "tbBG")
          UIToolbar.appearance().setBackgroundImage(tbBG, forToolbarPosition: .Any, barMetrics: .Default)
          
      
        toolBar.autoresizingMask = [.FlexibleTopMargin, .FlexibleWidth]
        self.view.addSubview(toolBar)
        phoneNumberField = UITextField(frame: CGRectMake(10.0, 6.0, 297, 40.0))
        phoneNumberField.backgroundColor = UIColor(patternImage: UIImage(named: "PhoneBG")!)
        phoneNumberField.attributedPlaceholder = NSAttributedString(string: "输入手机号", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        phoneNumberField.textAlignment = .Center
        phoneNumberField.textColor = .whiteColor()
        phoneNumberField.autoresizingMask = .FlexibleWidth
        toolBar.addSubview(phoneNumberField)
        captchaField = UITextField(frame: CGRectMake(10.0, 53.0, 178, 40.0))
        captchaField.backgroundColor = UIColor(patternImage: UIImage(named: "CodeBG")!)
        captchaField.attributedPlaceholder = NSAttributedString(string: "输入验证码", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        captchaField.textAlignment = .Center
        captchaField.textColor = .whiteColor()
        captchaField.autoresizingMask = .FlexibleWidth
        toolBar.addSubview(captchaField)
        
       
        nextStepButton.autoresizingMask = .FlexibleLeftMargin
        nextStepButton.setTitle("下一步", forState: .Normal)
        nextStepButton.alpha = 0.6
        nextStepButton.frame = CGRectMake(toolBar.bounds.size.width - 68.0, 6.0, 58.0, 29.0)
        nextStepButton.addTarget(self, action: "inputCaptcha", forControlEvents: .TouchUpInside)
        toolBar.addSubview(nextStepButton)
        let vericodeButton = UIButton(type: .System)
        vericodeButton.autoresizingMask = .FlexibleLeftMargin
        vericodeButton.setTitle("验证", forState: .Normal)
        vericodeButton.frame = CGRectMake(toolBar.bounds.size.width - 68.0, 46.0, 58.0, 29.0)
        vericodeButton.addTarget(self, action: "verifyCaptcha", forControlEvents: .TouchUpInside)
        toolBar.addSubview(vericodeButton)
        
        
        
        
        self.view.keyboardTriggerOffset = 120
        self.view.addKeyboardPanningWithFrameBasedActionHandler({ (keyboardFrameInView, opening, closing) -> Void in
            if self.isCaptchaFieldPresenting == false {
            var toolBarFrame = self.toolBar.frame
             toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height/2 + 5
             self.toolBar.frame = toolBarFrame
            }else{
                var toolBarFrame = self.toolBar.frame
                toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height
                self.toolBar.frame = toolBarFrame
            }
            }, constraintBasedActionHandler: nil)
        
    }
    
    func numberOfPages() -> Int {
        return 4
    }
    
    func configurePage(cell: GHWalkThroughPageCell!, atIndex index: Int) {
        cell.title = "郭寒"
      //  cell.titleImage = UIImage(named: "Tech")
        cell.desc = "一半是激素，一半是情怀。 -- Inverse"
    }
    
    func bgImageforPage(index: Int) -> UIImage! {
        if index == 0 {
            return UIImage(named: "GuoHan")
        }
        if index == 1 {
            return UIImage(named: "Tech")
        }
        
        return UIImage(named: "630")
    }
    
    func inputCaptcha() {
        
       BmobSMS.requestSMSCodeInBackgroundWithPhoneNumber(phoneNumberField.text, andTemplate: nil) { (number, error) -> Void in
          print(number)
        
        }
        nextStepButton.userInteractionEnabled = false
        phoneNumberField.resignFirstResponder()
        captchaField.becomeFirstResponder()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateCountDown", userInfo: nil, repeats: true)
        timer.fire()
        if isCaptchaFieldPresenting == false {
            isCaptchaFieldPresenting = true
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: { () -> Void in
                self.toolBar.frame.origin.y -= 45
                }, completion: nil)
        }
        
    }
    
    func updateCountDown() {
        countDown = countDown - 1
        nextStepButton.setTitle("\(countDown)", forState: .Normal)
        
        if countDown == 0 {
            nextStepButton.setTitle("下一步", forState: .Normal)
            nextStepButton.userInteractionEnabled = true
            timer.invalidate()
        }
    }
    
    func verifyCaptcha() {
        BmobUser.signOrLoginInbackgroundWithMobilePhoneNumber(phoneNumberField.text, andSMSCode: captchaField.text) { (_user, error) -> Void in
            if error == nil {
                let objectId = _user.objectId
                print(objectId)
                self.view.removeKeyboardControl()
                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let mainNaviController = storyBoard.instantiateViewControllerWithIdentifier("MainNaviController")
                self.tr_presentViewController(mainNaviController, method: TRPresentTransitionMethod.Fade)
                
            }else{
                let alert = UIAlertController(title: nil, message: "验证码输入有误！", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alert.addAction(okButton)
                self.presentViewController(alert, animated: false, completion: nil)
                
                
               
          
            }
        }
    }
    
    func keyboardWillHide() {
        isCaptchaFieldPresenting = false
        toolBar.frame.origin.y = self.view.bounds.size.height - 45.0
    }

   
}
