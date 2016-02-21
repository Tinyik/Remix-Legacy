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
        setUpViews()
    }
    
    
    func setUpViews() {
        let view = UIView(frame: CGRectMake((self.navigationController?.navigationBar.frame.size.width)!/2 - 80,0, 160, 35))
        
        let button1 = UIButton()
        let button2 = UIButton()
        let button3 = UIButton()
        button3.selected = true
        self.navigationItem.hidesBackButton = true
    
        let moreButton = UIButton(frame: CGRectMake(0,0,25,25))
        moreButton.setImage(UIImage(named: "more"), forState: .Normal)
        moreButton.addTarget(self, action: "presentSettingsVC", forControlEvents: .TouchUpInside)
        let backItem = UIBarButtonItem(customView: moreButton)
        self.navigationItem.rightBarButtonItem = backItem

        button1.setBackgroundImage(UIImage(named: "button1"), forState: .Selected)
        button3.setBackgroundImage(UIImage(named: "button3"), forState: .Selected)
        button2.setBackgroundImage(UIImage(named: "button2"), forState: .Selected)
        button1.setBackgroundImage(UIImage(named: "button1_normal"), forState: .Normal)
        button3.setBackgroundImage(UIImage(named: "button3_normal"), forState: .Normal)
        button2.setBackgroundImage(UIImage(named: "button2_normal"), forState: .Normal)
        button1.frame = CGRectMake(0, 10, 28, 26)
        button2.frame = CGRectMake(70, 10, 28, 26)
        button3.frame = CGRectMake(140, 10, 26, 26)
        view.addSubview(button1)
        view.addSubview(button2)
        view.addSubview(button3)
        button1.addTarget(self, action: "presentFirstVC", forControlEvents: .TouchUpInside)
         button2.addTarget(self, action: "presentSecondVC", forControlEvents: .TouchUpInside)
        self.navigationItem.titleView = view
    }
    
    func presentSettingsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsVC")
        let navigationController = UINavigationController(rootViewController: settingsVC)
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
    func presentSecondVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let categoryVC = storyBoard.instantiateViewControllerWithIdentifier("CategoryVC")
        let navigationController = UINavigationController(rootViewController: categoryVC)
        self.navigationController?.presentViewController(navigationController, animated: false, completion: nil)

        
    }
    
    func presentFirstVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let mainVC = storyBoard.instantiateViewControllerWithIdentifier("MainVC")
        let navigationController = UINavigationController(rootViewController: mainVC)
        self.navigationController?.presentViewController(navigationController, animated: false, completion: nil)

        
    }

    
    func fetchCloudData() {
        logoURLs = []
        names = []
        
        var query = BmobQuery(className: "Organization")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (organizations, error) -> Void in
            for org in organizations {
                let name = org.objectForKey("Name") as! String
                let logoFile = org.objectForKey("Logo") as! BmobFile
                let logoURL = NSURL(string: logoFile.url)!
                self.names.append(name)
                self.logoURLs.append(logoURL)
                
               self.orgsCollectionView.reloadData()
            }
        }
    }
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
 
    
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//         return UIEdgeInsetsMake(35, 20, 5, 20)
//    }
//    
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
        cell.logoImageView.sd_setImageWithURL(logoURLs[indexPath.row])
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
