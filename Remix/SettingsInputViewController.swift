//
//  SettingsInputViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/26/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

protocol SettingInputViewDelegate {
    func setEditingPropertyKey(key:String!)
    func setInputFieldPlaceHolder(placeHolder: String!)
    func setExplanationLabelText(explanation: String!)
    func setInputFieldText(text:String!)
}

class SettingsInputViewController: UIViewController, SettingInputViewDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var explanationLabel: UILabel!
    
    var editingKey: String!
    var explanation: String!
    var placeHolder: String!
    var text: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputField.delegate = self
        inputField.becomeFirstResponder()
        inputField.returnKeyType = .Done
        explanationLabel.text = explanation
        inputField.placeholder = placeHolder
        inputField.text = text
        let spaceView = UIView(frame: CGRectMake(0,0,10,10))
        inputField.leftViewMode = .Always
        inputField.leftView = spaceView
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: "saveEditedInformation")
        self.navigationItem.rightBarButtonItem?.tintColor = .blackColor()
        self.title = editingKey
        // Do any additional setup after loading the view.
    }
    
    func popCurrentVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setInputFieldPlaceHolder(placeHolder: String!) {
        self.placeHolder = placeHolder
    }
    
    func setExplanationLabelText(explanation: String!) {
        self.explanation = explanation
    }
    
    func setEditingPropertyKey(key: String!) {
        editingKey = key
    }
    
    func setInputFieldText(text: String!) {
        self.text = text
    }
    
    @IBAction func backGroundTap(sender: UIControl) {
        inputField.resignFirstResponder()
        
    }
    
    func saveEditedInformation() {
        inputField.resignFirstResponder()
        CURRENT_USER.setObject(inputField.text, forKey: editingKey)
        CURRENT_USER.updateInBackgroundWithResultBlock { (isSuccessful, error) -> Void in
            if isSuccessful == true {
                let alert = UIAlertController(title: "提示", message: "保存成功", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: { (alert) -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)

            }else{
                let alert = UIAlertController(title: "提示", message: "保存失败，请检查输入和网络设置。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        saveEditedInformation()
        return true
    }
}
