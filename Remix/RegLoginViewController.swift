//
//  RegLoginViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/9/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class RegLoginViewController: UIViewController, ModalTransitionDelegate, UITextFieldDelegate {

    var toolBar: UIToolbar!
    var phoneNumberField: UITextField!
    var captchaField: UITextField!
    var isCaptchaFieldPresenting = false
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    weak var modalDelegate: ModalViewControllerDelegate?
    
    var countDown = 60
    var timer: NSTimer!
    
    var  nextStepButton = UIButton(type: .System)
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        captchaField.delegate = self
        phoneNumberField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
       
        // Do any additional setup after loading the view.
    }
    
    func setUpViews() {
        
        let mainViewHeight = self.view.bounds.size.height
        let mainViewWidth = self.view.bounds.size.width
        
         toolBar = UIToolbar(frame: CGRectMake(0.0, mainViewHeight - 53.0, mainViewWidth, 112.0))
         let tbBG = UIImage(named: "tbBG")
          UIToolbar.appearance().setBackgroundImage(tbBG, forToolbarPosition: .Any, barMetrics: .Default)
          
      
        toolBar.autoresizingMask = [.FlexibleTopMargin, .FlexibleWidth]
        self.view.addSubview(toolBar)
        
        
        let rightButtonWidth: CGFloat = 58
        let phoneNumberFieldWidth: CGFloat = mainViewWidth - rightButtonWidth - 20
        
        phoneNumberField = UITextField(frame: CGRectMake(10.0, 6.0, phoneNumberFieldWidth, 40.0))
        phoneNumberField.returnKeyType = .Send
//        phoneNumberField.backgroundColor = UIColor(patternImage: UIImage(named: "PhoneBG")!)
        phoneNumberField.backgroundColor = UIColor(white: 0, alpha: 0.45)
        phoneNumberField.layer.cornerRadius = 20
        phoneNumberField.attributedPlaceholder = NSAttributedString(string: "输入手机号", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        phoneNumberField.textAlignment = .Center
        phoneNumberField.textColor = .whiteColor()
        phoneNumberField.autoresizingMask = .FlexibleWidth
        toolBar.addSubview(phoneNumberField)
        
        captchaField = UITextField(frame: CGRectMake(10.0, 53.0, 178, 40.0))
        captchaField.returnKeyType = .Done
//        captchaField.backgroundColor = UIColor(patternImage: UIImage(named: "CodeBG")!)
        captchaField.backgroundColor = UIColor(white: 0, alpha: 0.45)
        captchaField.layer.cornerRadius = 20
        captchaField.attributedPlaceholder = NSAttributedString(string: "输入验证码", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        captchaField.textAlignment = .Center
        captchaField.textColor = .whiteColor()
        captchaField.autoresizingMask = .FlexibleWidth
        toolBar.addSubview(captchaField)
        
       
        nextStepButton.autoresizingMask = .FlexibleLeftMargin
        nextStepButton.setTitle("下一步", forState: .Normal)
        nextStepButton.setTitleColor(.whiteColor(), forState: .Normal)
        nextStepButton.alpha = 0.6
        nextStepButton.frame = CGRectMake(toolBar.bounds.size.width - rightButtonWidth, 0, rightButtonWidth, 52)
        nextStepButton.addTarget(self, action: "inputCaptcha", forControlEvents: .TouchUpInside)
//        nextStepButton.backgroundColor = UIColor.redColor()
        toolBar.addSubview(nextStepButton)
        
        
        let vericodeButton = UIButton(type: .System)
        vericodeButton.autoresizingMask = .FlexibleLeftMargin
        vericodeButton.setTitle("完成", forState: .Normal)
        vericodeButton.setTitleColor(.whiteColor(), forState: .Normal)
        vericodeButton.frame = CGRectMake(toolBar.bounds.size.width - rightButtonWidth, 53, rightButtonWidth, 42)
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
    
    @IBAction func startInput() {
        phoneNumberField.becomeFirstResponder()
    }
    @IBAction func showRemixConditions() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let termsVC = storyBoard.instantiateViewControllerWithIdentifier("TermsVC")
        self.tr_presentViewController(termsVC, method: TRPresentTransitionMethod.PopTip(visibleHeight: 400))
    }
    
    func inputCaptcha() {
        if phoneNumberField.text == "AppStoreDEMO" {
            BmobUser.loginInbackgroundWithAccount("appstoredemo", andPassword: "demo", block: { (user, error) -> Void in
                if error == nil {
                    CURRENT_USER = user
                    self.view.removeKeyboardControl()
                    REMIX_CITY_NAME = CURRENT_USER.objectForKey("City") as! String
                    sharedOneSignalInstance.sendTag("City", value: REMIX_CITY_NAME)
                    let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let vc1 = storyBoard.instantiateViewControllerWithIdentifier("MainVC")
                    let vc2 = storyBoard.instantiateViewControllerWithIdentifier("CategoryVC")
                    let vc3 = storyBoard.instantiateViewControllerWithIdentifier("OrgsVC")
                    let pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
                    naviController = RMSwipeBetweenViewControllers(rootViewController: pageController)
                    naviController.viewControllerArray.addObjectsFromArray([vc1, vc2, vc3])
                    naviController.buttonText = ["活动", "分类", "组织"]
                    naviController.rm_delegate = vc1 as! RMSwipeBetweenViewControllersDelegate
                    naviController.rm_delegate2 = vc3 as! RMSwipeBetweenViewControllersDelegate
                    self.tr_presentViewController(naviController, method: TRPresentTransitionMethod.Fade)

                }
            })
        }else{
            
       BmobSMS.requestSMSCodeInBackgroundWithPhoneNumber(phoneNumberField.text, andTemplate: nil) { (number, error) -> Void in
        if error == nil {
            self.nextStepButton.userInteractionEnabled = false
            self.phoneNumberField.resignFirstResponder()
            self.captchaField.becomeFirstResponder()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateCountDown", userInfo: nil, repeats: true)
            self.timer.fire()
            if self.isCaptchaFieldPresenting == false {
                self.isCaptchaFieldPresenting = true
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .CurveEaseInOut, animations: { () -> Void in
                    self.toolBar.frame.origin.y -= 45
                    }, completion: nil)
            }

        }else{
            let alert = UIAlertController(title: nil, message: "诶？手机号格式好像有错误😣", preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "重试", style: .Cancel, handler: nil)
            alert.addAction(okButton)
            self.presentViewController(alert, animated: true, completion: nil)

        }
        
        }
        }
        
    }
    
    func updateCountDown() {
        countDown = countDown - 1
        nextStepButton.setTitle("\(countDown)", forState: .Normal)
        
        if countDown == 0 {
            nextStepButton.setTitle("下一步", forState: .Normal)
            nextStepButton.userInteractionEnabled = true
            timer.invalidate()
            countDown = 60
        }
    }
    
    func verifyCaptcha() {
        BmobUser.signOrLoginInbackgroundWithMobilePhoneNumber(phoneNumberField.text, andSMSCode: captchaField.text) { (_user, error) -> Void in
            if error == nil {
                self.view.removeKeyboardControl()
                CURRENT_USER = _user
                if _user.objectForKey("City") == nil {
                    CURRENT_USER.setObject("全国", forKey: "City")
                    CURRENT_USER.updateInBackground()
                }
                REMIX_CITY_NAME = CURRENT_USER.objectForKey("City") as! String
                sharedOneSignalInstance.sendTag("City", value: REMIX_CITY_NAME)
                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let vc1 = storyBoard.instantiateViewControllerWithIdentifier("MainVC")
                let vc2 = storyBoard.instantiateViewControllerWithIdentifier("CategoryVC")
                let vc3 = storyBoard.instantiateViewControllerWithIdentifier("OrgsVC")
                let pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
                naviController = RMSwipeBetweenViewControllers(rootViewController: pageController)
                naviController.viewControllerArray.addObjectsFromArray([vc1, vc2, vc3])
                naviController.buttonText = ["活动", "分类", "组织"]
                naviController.rm_delegate = vc1 as! RMSwipeBetweenViewControllersDelegate
                naviController.rm_delegate2 = vc3 as! RMSwipeBetweenViewControllersDelegate
                self.tr_presentViewController(naviController, method: TRPresentTransitionMethod.Fade)
                
            }else{
                let alert = UIAlertController(title: nil, message: "验证码似乎不正确哦😣", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "重试", style: .Cancel, handler: nil)
                alert.addAction(okButton)
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == phoneNumberField {
            inputCaptcha()
        }
        
        if textField == captchaField {
            verifyCaptcha()
        }
        
        return true
    }
    
    func keyboardWillHide() {
        if isCaptchaFieldPresenting == false {
            toolBar.frame.origin.y = self.view.bounds.size.height - 45.0
        }else{
             toolBar.frame.origin.y = self.view.bounds.size.height - 90.0
        }
    }

   
}
