//
//  CandidatesViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class CandidatesViewController: UITableViewController {
    
    var objectId: String = ""
    var orders: [BmobObject] = []
    var customers: [BmobObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        
    }

    func fetchCloudData() {
        orders = []
        customers = []
        let query = BmobQuery(className: "Orders")
        query.whereKey("ParentActivityObjectId", equalTo: objectId)
        query.findObjectsInBackgroundWithBlock { (orders, error) -> Void in
            if error == nil {
                for order in orders {
                    print("ORDER")
                    self.orders.append(order as! BmobObject)
                    let query2 = BmobQuery(className: "_User")
                    query2.getObjectInBackgroundWithId(order.objectForKey("CustomerObjectId") as! String, block: { (user, error) -> Void in
                        print("USER")
                        if error == nil {
                            self.customers.append(user)
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return customers.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! CandidateCell
        cell.nameLabel.text = customers[indexPath.row].objectForKey("LegalName") as? String
        cell.detailLabel.text = customers[indexPath.row].objectForKey("email") as? String
        let url = NSURL(string: (customers[indexPath.row].objectForKey("Avatar") as! BmobFile).url)
        cell.avatarView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "DefaultAvatar"))
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
