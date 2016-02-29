//
//  LocationViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices

class LocationViewController: UITableViewController, UIGestureRecognizerDelegate {
    
        var photoURLArray: [[NSURL]] = []
        var locationObjects: [BmobObject] = []
        let photoKeys = ["Pic0", "Pic1", "Pic2", "Pic3", "Pic4", "Pic5", "Pic6", "Pic7", "Pic8"]
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tableView.separatorStyle = .None
            let backButton = UIButton(frame: CGRectMake(0,0,30,30))
            backButton.setImage(UIImage(named: "back"), forState: .Normal)
            backButton.addTarget(self, action: "popCurrentVC", forControlEvents: .TouchUpInside)
            let backItem = UIBarButtonItem(customView: backButton)
            self.navigationItem.leftBarButtonItem = backItem
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            self.navigationController?.navigationBar.translucent = false
            self.title = "好去处"
            fetchCloudData()
        }
        
        
        // MARK: - Table view data sourcey
        
        func fetchCloudData() {
         
            let query = BmobQuery(className: "Location")
            query.whereKey("isVisibleToUsers", equalTo: true)
            query.findObjectsInBackgroundWithBlock { (locationObjects, error) -> Void in
                if locationObjects.count > 0 {
                    for location in locationObjects {
                        var imageURLs:[NSURL] = []
                        for key in self.photoKeys {
                            
                            if let imageFile = location.objectForKey(key) as? BmobFile {
                                let imageURL = NSURL(string: imageFile.url)!

                                imageURLs.append(imageURL)
                            }
                        }

                        self.photoURLArray.append(imageURLs)
                        self.locationObjects.append(location as! BmobObject)
                        
                       
                    }
                    print(self.photoURLArray)
                    self.tableView.reloadData()
                }
                
               
            }
            
        }
    

    
        func popCurrentVC() {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
        
            return locationObjects.count
        }
        
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            
            return 1
        }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if locationObjects[indexPath.row].objectForKey("isFeatured") as! Bool == false{
            return UITableViewAutomaticDimension
        }
        else{
            return DEVICE_SCREEN_WIDTH
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 530
    }
        
        
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            if locationObjects[indexPath.row].objectForKey("isFeatured") as! Bool == false {
                let cell = tableView.dequeueReusableCellWithIdentifier("locationTVCIdentifier") as! LocationTableViewCell
                cell.photoURLs = photoURLArray[indexPath.row]
                print("ARRAY")
                print(photoURLArray[indexPath.row])
                print("ARRAY")
             //   print(photoURLArray[indexPath.row][0])
                cell.parentViewController = self
                cell.titleLabel.text = locationObjects[indexPath.row].objectForKey("Title") as! String
                cell.desLabel.text = locationObjects[indexPath.row].objectForKey("Description") as? String
                cell.orgLabel.text = locationObjects[indexPath.row].objectForKey("Org") as? String
                cell.locationLabel.text = locationObjects[indexPath.row].objectForKey("Location") as? String
                cell.locationPhotoView.reloadData()
                return cell
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier("locationFullCell") as! LocationFullCoverCell
                cell.desLabel.text = locationObjects[indexPath.row].objectForKey("Description") as? String
                cell.orgLabel.text = locationObjects[indexPath.row].objectForKey("Org") as? String
                cell.locationLabel.text = locationObjects[indexPath.row].objectForKey("Location") as? String
                cell.coverImgView.sd_setImageWithURL(photoURLArray[indexPath.row][0], placeholderImage: UIImage(named: "SDPlaceholder"))
                return cell
            }
        }
        
        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            
            // FIXME: 非空判断
            let query = BmobQuery(className: "Location")
            let objectId = locationObjects[indexPath.row].objectId
            query.getObjectInBackgroundWithId(objectId) { (locationObject, error) -> Void in
                locationObject.incrementKey("PageView", byAmount: 1)
                locationObject.updateInBackground()
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if #available(iOS 9.0, *) {
                
                let safariView = SFSafariViewController(URL: NSURL(string: locationObjects[indexPath.row].objectForKey("URL") as! String)!, entersReaderIfAvailable: false)
                safariView.view.tintColor = UIColor(red: 74/255, green: 144/255, blue: 224/255, alpha: 1)
                self.navigationController?.presentViewController(safariView, animated: true, completion: nil)
                
            } else {
                
                let webView = RxWebViewController(url: NSURL(string: locationObjects[indexPath.row].objectForKey("URL") as! String)!)
                self.navigationController?.pushViewController(webView, animated: true)
                
            }
            
            
        }
    
   
        
    

}
