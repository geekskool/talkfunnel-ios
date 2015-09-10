//
//  EventListViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 11/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

protocol EventListViewControllerDelegate {
    func didSelectEvent(event: EventList)
    func triedToRefreshEventList(done: Bool)
}
class EventListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var requiredEventList = [EventList]()
    var delegate: EventListViewControllerDelegate?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshControl()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = self.view.frame.height/4
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    func refresh() {
        tableView.reloadData()
    }

    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.orangeColor()
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refreshData(sender: AnyObject) {
        fetchAllData { (done, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let delegate = self.delegate {
                    delegate.triedToRefreshEventList(done)
                }
            })
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCellWithIdentifier("Events", forIndexPath: indexPath) as UITableViewCell
        
        let event = eventList
        let e = event[indexPath.row]
        cell.textLabel?.text = e.title
        cell.textLabel?.textColor = UIColor.purpleColor()
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 30)
        cell.detailTextLabel?.text = e.dateLocation
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let delegate = self.delegate {
            delegate.didSelectEvent(eventList[indexPath.row])
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
