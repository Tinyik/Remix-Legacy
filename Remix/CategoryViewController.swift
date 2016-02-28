//
//  CategoryViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

protocol ActivityFilterDelegate {
    func filterQueryWithCategoryOrLabelName(name: String)
    func setParallaxHeaderImage(headerImageURL: NSURL)
}

class CategoryViewController: UITableViewController {
    
    var categoryName = ""
    var delegate: ActivityFilterDelegate!
    var filteredParallaxImageURL: NSURL!
    

    var coverImageURLs: [NSURL] = []
    var coverTitles: [String] = []
    var cloudCoverTitles: [String] = []
    
    @IBOutlet weak var showGallery: UIImageView!
    @IBOutlet weak var showLiked: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        fetchCloudData()
        self.navigationController?.navigationBar.translucent = false
        tableView.separatorStyle = .None
        self.tableView.delegate = self
        self.tableView.dataSource = self
        showGallery.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "showGalleryAction")
        showGallery.addGestureRecognizer(tap)
        showGallery.clipsToBounds = true
        showGallery.contentMode = .ScaleAspectFill
        showGallery.layer.cornerRadius = 8

    }

    func setUpViews() {
        self.navigationItem.hidesBackButton = true
        showGallery.userInteractionEnabled = true
        let tapShowGallery = UITapGestureRecognizer(target: self, action: "showGalleryAction")
        showGallery.addGestureRecognizer(tapShowGallery)
        showGallery.clipsToBounds = true
        showGallery.contentMode = .ScaleAspectFill
        showGallery.layer.cornerRadius = 8
        showLiked.userInteractionEnabled = true
        let tapShowLiked = UITapGestureRecognizer(target: self, action: "showLikedAction")
        showLiked.addGestureRecognizer(tapShowLiked)
        showLiked.clipsToBounds = true
        showLiked.contentMode = .ScaleAspectFill
        showLiked.layer.cornerRadius = 8
        let likedMaskView = UIView(frame: CGRectMake(0,0,500,500))
        likedMaskView.backgroundColor = .blackColor()
        likedMaskView.alpha = 0.3
        let galleryMaskView = UIView(frame: CGRectMake(0,0,500,500))
        galleryMaskView.backgroundColor = .blackColor()
        galleryMaskView.alpha = 0.3
        showLiked.addSubview(likedMaskView)
        showGallery.addSubview(galleryMaskView)
        
    }
    
    func fetchCloudData() {
        let query = BmobQuery(className: "Category")
        query.findObjectsInBackgroundWithBlock { (categories, error) -> Void in
            for category in categories {
                let databaseName = category.objectForKey("Name") as! String
                self.cloudCoverTitles.append(databaseName)
                let url = NSURL(string: (category.objectForKey("CoverImage") as! BmobFile).url)
                self.coverImageURLs.append(url!)
                let displayName = category.objectForKey("DisplayName") as! String
                self.coverTitles.append(displayName)
            }
            self.tableView.reloadData()
        }
    }
    
    
    func showGalleryAction() {
        self.performSegueWithIdentifier("showGallery", sender: nil)
        print("Success")
    }
    
    func showLikedAction() {
         self.performSegueWithIdentifier("showLiked", sender: nil)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! CTTableViewCell
        cell.coverImageView.sd_setImageWithURL(coverImageURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        cell.titleLabel.text = coverTitles[indexPath.row]
        
        return cell

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coverImageURLs.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let query = BmobQuery(className: "Category")
        query.whereKey("Name", equalTo: cloudCoverTitles[indexPath.row])
        query.findObjectsInBackgroundWithBlock { (categories, error) -> Void in
            if error == nil {
                for category in categories {
                    category.incrementKey("PageView", byAmount: 1)
                    category.updateInBackground()
                }
            }
        }
        self.categoryName = cloudCoverTitles[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        filteredParallaxImageURL = coverImageURLs[indexPath.row]
        self.performSegueWithIdentifier("showFilteredView", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("pre")
        if segue.identifier == "showFilteredView" {
            if let fVC = segue.destinationViewController as? CTFilteredViewController {
               
                self.delegate = fVC
                self.delegate.filterQueryWithCategoryOrLabelName(categoryName)
                self.delegate.setParallaxHeaderImage(filteredParallaxImageURL)

            }
        }
    }
}
