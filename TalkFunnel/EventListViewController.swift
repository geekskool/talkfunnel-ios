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
        let cell = tableView.dequeueReusableCellWithIdentifier("Events", forIndexPath: indexPath) as! EventListTableViewCell
        
        let event = eventList
        let e = event[indexPath.row]
        cell.setCell(e)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let delegate = self.delegate {
            delegate.didSelectEvent(eventList[indexPath.row])
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
