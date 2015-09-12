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
    func showStillLoadingClickedEventAlert()
}
class EventListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var requiredEventList = [EventList]()
    var delegate: EventListViewControllerDelegate?
    var refreshControl: UIRefreshControl!
    
    var isRefreshing = false
    var isLoadingNewEvent = false
    var newEventSelected = currentEvent?.title
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshControl()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refreshControl.endRefreshing()
    }
    
    func refresh() {
        tableView.reloadData()
    }

    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor(red: 235/255, green: 91/255, blue: 35/255, alpha: 1)
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refreshData(sender: AnyObject) {
        if !isRefreshing {
            isRefreshing = true
            fetchAllData { (done, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let delegate = self.delegate {
                        delegate.triedToRefreshEventList(done)
                    }
                })
            }
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
        
        if isLoadingNewEvent {
            if let delegate = self.delegate {
                delegate.showStillLoadingClickedEventAlert()
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else {
            isLoadingNewEvent = true
            if let delegate = self.delegate {
                delegate.didSelectEvent(eventList[indexPath.row])
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }
    
    func didFinishLoadingNewEvent() {
        isLoadingNewEvent = false
    }
    
}
