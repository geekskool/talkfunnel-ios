//
//  SavedContactsListViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 06/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit
import CoreData

class SavedContactsListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: TableViewDataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = savedContacts.count
        if count == 0 {
            addMessageLabel()
        }
        return count
    }
    
    private func addMessageLabel() {
        let messageLabel = UILabel()
        messageLabel.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.text = "No Contacts have been saved yet"
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.backgroundColor = UIColor.whiteColor()
        messageLabel.font = UIFont(name: "Helvetica", size: 25)
        messageLabel.numberOfLines = 0
        view.addSubview(messageLabel)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactInformationCell", forIndexPath: indexPath) as! ContactTableViewCell
        let contact = savedContacts[indexPath.row]
        cell.setData(contact)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
