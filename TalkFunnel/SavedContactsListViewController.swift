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
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        refreshControl.endRefreshing()
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
            var num = 0
            for var i = 0; i < savedContacts.count; i++ {
                if savedContacts[i].phoneNumber == nil {
                    let string = savedContacts[i].participantDataUrl! + "participant?puk=" + savedContacts[i].publicKey! + "&key=" + savedContacts[i].privateKey!
                    num++
                    fetchSavedContactData(string, callback: { (done, error) -> Void in
                        num--
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if let delegate = self.delegate {
                                if let updatedContactInfo = scannedParticipantInfo {
                                    for var j = 0; j < savedContacts.count ;j++ {
                                        if savedContacts[j].publicKey == updatedContactInfo.publicKey {
                                            let temp = savedContacts[j].privateKey
                                            savedContacts[j] = updatedContactInfo
                                            savedContacts[j].privateKey = temp
                                        }
                                    }
                                }
                                if num == 0 {
                                    delegate.triedToRefreshContactList(done)
                                }
                            }
                            
                        })
                    })
                }
            }
            
            if num == 0 {
                delegate?.triedToRefreshContactList(false)
            }
            
            
        }
                
    }
    
    func refresh() {
        messageLabel.removeFromSuperview()
        tableView.reloadData()
    }
    
    func fetchParticipantListFromServer(callback: Bool -> Void) {
        fetchParticipantData({ done -> Void in
            callback(done)
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
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel!.textColor = UIColor.lightGrayColor()
        header.textLabel?.textAlignment = .Center
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Pull down to refresh"
    }
    
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
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
