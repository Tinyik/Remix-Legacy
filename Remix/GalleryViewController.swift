//
//  GalleryViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/7/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices
import MWPhotoBrowser

class GalleryViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var photoURLArray: [[[NSURL]]] = []
    var mwPhotos: [MWPhoto] = []
    var galleryObjects: [[BmobObject]] = []
    var monthNameStrings: [String] = []
    var dateLabel: UILabel!
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
        fetchCloudData()
            
          }


    // MARK: - Table view data sourcey
    
    func fetchCloudData() {
        var query = BmobQuery(className: "Gallery")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (galleryObjects, error) -> Void in
            if galleryObjects.count > 0 {
                for gallery in galleryObjects {
                    var imageURLs:[NSURL] = []
                    for key in self.photoKeys {
                        
                        if let imageFile = gallery.objectForKey(key) as? BmobFile {
                        let imageURL = NSURL(string: imageFile.url)!
                        imageURLs.append(imageURL)
                        }
                    }
      
                    
                    let dateString = gallery.objectForKey("Date") as! String
                    let monthName = dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[0] + " " + dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[2]
                    if self.isMonthAdded(monthName) == false {
                        self.monthNameStrings.append(monthName)
                        self.galleryObjects.append([gallery as! BmobObject])
                        self.photoURLArray.append([imageURLs])
                    } else {
                        
                        if let index = self.galleryObjects.indexOf({
                            
                            ($0[0].objectForKey("Date") as! String).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[0] + " " + dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[2] == monthName})
                        {
                            self.galleryObjects[index].append(gallery as! BmobObject)
                            self.photoURLArray[index].append(imageURLs)
                        }
                        
                    }
                    
                    
                    
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    func isMonthAdded(monthName: String) -> Bool {
        
        for _date in monthNameStrings {
            if _date == monthName {
                return true
            }
        }
        return false
    }
    
    func popCurrentVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
        return galleryObjects[section].count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
  
        return monthNameStrings.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
 
        let dateHeaderView = UIView(frame: CGRectMake(30,0,UIScreen.mainScreen().bounds.width, 50))
        
        dateHeaderView.backgroundColor = .whiteColor()
        dateHeaderView.layer.shadowColor = UIColor.blackColor().CGColor
        dateHeaderView.layer.shadowOpacity = 0.08
        dateHeaderView.layer.shadowOffset = CGSizeMake(0, 0.7)
        dateLabel = UILabel(frame: CGRectMake(0,0,300,390))
        dateLabel.text = monthNameStrings[section]
        dateLabel.font = UIFont.systemFontOfSize(19)
        dateLabel.sizeToFit()
        dateHeaderView.addSubview(dateLabel)
        dateLabel.center = dateHeaderView.center
        dateLabel.center.x = UIScreen.mainScreen().bounds.width/2
        return dateHeaderView
        
        
    }
    
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
        return  53
    }
    


    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("galleryTVCIdentifier") as! GalleryTableViewCell
        cell.photoURLs = photoURLArray[indexPath.section][indexPath.row]
        cell.titleLabel.text = galleryObjects[indexPath.section][indexPath.row].objectForKey("Title") as! String
        cell.desLabel.text = galleryObjects[indexPath.section][indexPath.row].objectForKey("Description") as! String
        cell.parentViewController = self
        cell.orgLabel.text = galleryObjects[indexPath.section][indexPath.row].objectForKey("Org") as! String
        cell.timeLabel.text = galleryObjects[indexPath.section][indexPath.row].objectForKey("Date") as! String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // FIXME: 非空判断
        var query = BmobQuery(className: "Gallery")
        let objectId = galleryObjects[indexPath.section][indexPath.row].objectId
        query.getObjectInBackgroundWithId(objectId) { (galleryObject, error) -> Void in
            galleryObject.incrementKey("PageView", byAmount: 1)
            galleryObject.updateInBackground()
        }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if #available(iOS 9.0, *) {
  
                let safariView = SFSafariViewController(URL: NSURL(string: galleryObjects[indexPath.section][indexPath.row].objectForKey("URL") as! String)!, entersReaderIfAvailable: true)
                safariView.view.tintColor = UIColor(red: 74/255, green: 144/255, blue: 224/255, alpha: 1)
                self.navigationController?.presentViewController(safariView, animated: true, completion: nil)
                
            } else {
               
                let webView = RxWebViewController(url: NSURL(string: galleryObjects[indexPath.section][indexPath.row].objectForKey("URL") as! String)!)
                self.navigationController?.pushViewController(webView, animated: true)
                
            }
            
        
    }
    
   
}
