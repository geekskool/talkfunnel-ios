//
//  SavedContactsListViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 06/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit
import CoreData

protocol SavedContactsListViewControllerDelegate {
    func triedToRefreshContactList(done: Bool)
}

class SavedContactsListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let messageLabel = UILabel()
    var refreshControl: UIRefreshControl!
    var delegate: SavedContactsListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshControl()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.orangeColor()
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refreshData(sender: AnyObject) {
        if savedContacts.count == 0 {
            refreshControl.endRefreshing()
        }
        else {
            for contact in savedContacts {
                let string = contact.participantDataUrl! + "participant?puk=" + scannedContactPublicKey! + "&key=" + scannedContactPrivateKey!
                fetchSavedContactData(string, callback: { (done, error) -> Void in
                    if let delegate = self.delegate {
                        delegate.triedToRefreshContactList(done)
                    }
                })
            }
        }
    }
    
    func refresh() {
        tableView.reloadData()
    }
    
    func fetchParticipantListFromServer() {
        self.refreshControl.beginRefreshing()
        fetchParticipantData({ done -> Void in
            if let delegate = self.delegate {
                delegate.triedToRefreshContactList(done)
            }
        })
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
        messageLabel.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.text = "No Contacts saved yet.Pull down to refresh"
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.backgroundColor = UIColor.clearColor()
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
