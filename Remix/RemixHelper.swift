//
//  RemixHelper.swift
//  Remix
//
//  Created by fong tinyik on 4/17/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

public class RemixHelper {
    
    class func activityStatusChangeNotification(phoneNumbers: [String], isSuccessful: Bool, remark: String!) {
        
        for phoneNumber in phoneNumbers {
            if isSuccessful {
                AVOSCloud.requestSmsCodeWithPhoneNumber(phoneNumber, templateName: "ActivityRevision_Success", variables: nil, callback: { (isSuccessful, error) in
                    if isSuccessful {
                        print("SMS Sent Successfully")
                    }else{
                        print("SMS Sent Failed")
                        print(error.description)
                    }
                })
            }else{
                AVOSCloud.requestSmsCodeWithPhoneNumber(phoneNumber, templateName: "ActivitySubm_Fail", variables: ["reason": remark], callback: { (isSuccessful, error) in
                    if isSuccessful {
                        print("SMS Sent Successfully")
                    }else{
                        print("SMS Sent Failed")
                        print(error.description)
                    }
                })
            }

        }
    
    }
    
    class func newOrderNotification(phoneNumbers: [String]) {
        for phoneNumber in phoneNumbers {
            AVOSCloud.requestSmsCodeWithPhoneNumber(phoneNumber, templateName: "New_Order", variables: nil) { (isSuccessful, error) in
                if isSuccessful {
                    print("SMS Sent Successfully")
                }else{
                    print("SMS Sent Failed")
                    print(error.description)
                }
            }

        }
    
    }

}
