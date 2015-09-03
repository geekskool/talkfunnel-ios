//
//  EventListViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 11/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class EventListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var requiredEventList = [EventList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = self.view.frame.height/4
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
        currentEvent = eventList[indexPath.row]
        fetchDataForEvent { (doneFetching) -> Void in
            if doneFetching {
                eventInfoVC.refresh()
                talksVC.refresh()
                pageController!.currentPage = 2
                
            }
        }
    }

}
