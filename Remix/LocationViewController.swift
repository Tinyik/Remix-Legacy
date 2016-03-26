//
//  LocationViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import TTGSnackbar

class LocationViewController: UITableViewController {
    
    var photoURLArray: [[NSURL]] = []
    var locationObjects: [AVObject] = []
    let photoKeys = ["Pic0", "Pic1", "Pic2", "Pic3", "Pic4", "Pic5", "Pic6", "Pic7", "Pic8"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .None
        self.navigationController?.navigationBar.tintColor = .whiteColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加地点", style: .Plain, target: self, action: "addLocation")
        self.title = APPLICATION_UI_REMOTE_CONFIG.objectForKey("LocationLabel_Text") as? String
        fetchCloudData()
    }
    
    
    func addLocation() {
        let submVC = LocationSubmissionViewController()
        let navigationController = RMNavigationController(rootViewController: submVC)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func fetchCloudData() {
        
        let query = AVQuery(className: "Location")
        query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (locationObjects, error) -> Void in
            
            if error == nil {
                if locationObjects.count > 0 {
                    for location in locationObjects {
                        var imageURLs:[NSURL] = []
                        for key in self.photoKeys {
                            
                            if let imageFile = location.objectForKey(key) as? AVFile {
                                let imageURL = NSURL(string: imageFile.url)!
                                
                                imageURLs.append(imageURL)
                            }
                        }
                        
                        self.photoURLArray.append(imageURLs)
                        self.locationObjects.append(location as! AVObject)
                        
                        
                    }
                    
                    self.tableView.reloadData()
                }
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
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
        
        
        let query = AVQuery(className: "Location")
        query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
        let objectId = locationObjects[indexPath.row].objectId
        sharedOneSignalInstance.sendTag(objectId, value: "LocationVisited")
        query.getObjectInBackgroundWithId(objectId) { (locationObject, error) -> Void in
            if error == nil {
                locationObject.incrementKey("PageView", byAmount: 1)
                locationObject.saveInBackground()
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let url = locationObjects[indexPath.row].objectForKey("URL") as? String {
            let webView = RxWebViewController(url: NSURL(string: url))
            self.navigationController?.pushViewController(webView, animated: true)
        }
        
        
    }
    
    
    
    
    
}
