//
//  OrgsViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

protocol OrganizationViewDelegate {
    func filterQueryWithOrganizationName(name: String)
    
}

class OrgsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var orgsCollectionView: UICollectionView!
    
    var organizationName = ""
    var delegate: OrganizationViewDelegate!
    var filteredParallaxImageURL: NSURL!
    
    var logoURLs: [NSURL] = []
    var names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orgsCollectionView.delegate = self
        orgsCollectionView.dataSource = self
        fetchCloudData()

    }
    
    
    
    func fetchCloudData() {
        logoURLs = []
        names = []
        
        let query = BmobQuery(className: "Organization")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (organizations, error) -> Void in
            for org in organizations {
                let name = org.objectForKey("Name") as! String
                let logoFile = org.objectForKey("Logo") as! BmobFile
                let logoURL = NSURL(string: logoFile.url)!
                self.names.append(name)
                self.logoURLs.append(logoURL)
            }
            self.orgsCollectionView.reloadData()
        }
    }
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
 
    
  
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(collectionView.frame.size.width/3, 130)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    

    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return names.count
    }
    
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = orgsCollectionView.dequeueReusableCellWithReuseIdentifier("reuseIdentifier", forIndexPath: indexPath) as! OrgCell
        cell.logoImageView.sd_setImageWithURL(logoURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        cell.orgNameLabel.text = names[indexPath.row]
        
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        orgsCollectionView.deselectItemAtIndexPath(indexPath, animated: false)
        self.organizationName = names[indexPath.row]
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("showOrgHomepage", sender: nil)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
        if segue.identifier == "showOrgHomepage" {
            if let fVC = segue.destinationViewController as? OrgFilteredViewController {
                
                self.delegate = fVC
                self.delegate.filterQueryWithOrganizationName(organizationName)
    
                
            }
        }
    }
    
  
}
