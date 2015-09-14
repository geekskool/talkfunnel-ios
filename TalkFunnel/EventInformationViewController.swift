//
//  EventInformationViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 11/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

protocol EventInformationViewControllerDelegate {
    func didSelectTalk(talk: Session)
    func triedToRefreshEventInfo(done: Bool)
}
class EventInformationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewForSchedule: UITableView!

    var dailyColors = [UIColor]()
    var breakColors = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    let messageLabel = UILabel()
    let loadingView = UIView()
    var delegate: EventInformationViewControllerDelegate?
    var refreshControl: UIRefreshControl!
    var isRefreshing = false
    
    private struct constants {
        static let breakCellReuseIdentifier = "Break"
        static let scheduleCellReuseIdentifier = "Schedule"
        static let showEventInfo = "Show Event Information"
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshControl()
        tableViewForSchedule.delegate = self
        tableViewForSchedule.dataSource = self
        tableViewForSchedule.estimatedRowHeight = tableViewForSchedule.rowHeight
        tableViewForSchedule.rowHeight = UITableViewAutomaticDimension
        
        tableViewForSchedule.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refreshControl.endRefreshing()
    }
    
    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor(red: 235/255, green: 91/255, blue: 35/255, alpha: 1)
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableViewForSchedule.addSubview(refreshControl)
    }
    
    func refreshData(sender: AnyObject) {
        if !isRefreshing {
            isRefreshing = true
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                fetchDataForEvent({ (done, error) -> Void in
                    if let delegate = self.delegate {
                        delegate.triedToRefreshEventInfo(done)
                    }
                })
            }
        }
    }
    
    func refresh() {
        messageLabel.removeFromSuperview()
        loadingView.removeFromSuperview()
        tableViewForSchedule.reloadData()
    }
    
    func addLoadingDataView() {
        loadingView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.height)
        loadingView.backgroundColor = UIColor.whiteColor()
        
        let loadingIcon = UIActivityIndicatorView()
        loadingIcon.frame.origin = CGPointMake(loadingView.frame.width/2, loadingView.frame.height/2)
        loadingIcon.color = UIColor.orangeColor()
        loadingView.addSubview(loadingIcon)
        view.addSubview(loadingView)
        
        loadingIcon.startAnimating()
        
    }
    
    // MARK: - Table view data source
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel!.textColor = UIColor.lightGrayColor()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionName = currentEventInformation?.schedule[section].date {
            return formatDate(sectionName)
        }
        return ""
    }
    
    //to format the date to a medium style like , 2015-08-16 to August 16,2015
    func formatDate(sectionName: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.dateFromString(sectionName)
        dateFormatter.dateStyle = .FullStyle
        return dateFormatter.stringFromDate(date!)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let count = schedule.count
        if count == 0 {
            addMessageLabel()
        }
        return count
    }
    
    private func addMessageLabel() {
        messageLabel.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.text = "Schedule for this Event has not been decided yet"
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.font = UIFont(name: "Helvetica", size: 25)
        messageLabel.numberOfLines = 0
        view.addSubview(messageLabel)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let talk = schedule[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(constants.breakCellReuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        if let isBreak = talk.isBreak {
            if isBreak {
                cell.textLabel?.text = getTimeFromDate(talk.startTime!)
                cell.detailTextLabel?.text = talk.title
                cell.userInteractionEnabled = false
            }
            else {
                let scheduleCell = tableView.dequeueReusableCellWithIdentifier(constants.scheduleCellReuseIdentifier, forIndexPath: indexPath) as! ScheduleTableViewCell
                scheduleCell.session = talk
                return scheduleCell
            }
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let selectedTalk = schedule[indexPath.section][indexPath.row]
        if let delegate = self.delegate {
            delegate.didSelectTalk(selectedTalk)
        }
    }
    
    
    func getTimeFromDate(dateString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ" //iso 8601
        let date = dateFormatter.dateFromString(dateString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "HH:mm" // 08:30
        return newDateFormatter.stringFromDate(date!)
    }
    
    
}


