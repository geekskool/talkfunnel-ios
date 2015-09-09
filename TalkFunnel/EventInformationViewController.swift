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
}
class EventInformationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewForSchedule: UITableView!

    var dailyColors = [UIColor]()
    var breakColors = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    let messageLabel = UILabel()
    let loadingView = UIView()
    var delegate: EventInformationViewControllerDelegate?

    private struct constants {
        static let breakCellReuseIdentifier = "Break"
        static let scheduleCellReuseIdentifier = "Schedule"
        static let showEventInfo = "Show Event Information"
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the delegate and the datasource of the table view to be the instance of this class (UI View controller)
        tableViewForSchedule.delegate = self
        tableViewForSchedule.dataSource = self
        
        //To make the row height dynamic
        tableViewForSchedule.estimatedRowHeight = tableViewForSchedule.rowHeight
        tableViewForSchedule.rowHeight = UITableViewAutomaticDimension
        print("done")
    }
    
    func refresh() {
        messageLabel.removeFromSuperview()
        loadingView.removeFromSuperview()
        tableViewForSchedule.reloadData()
    }
    
    func addLoadingDataView() {
        loadingView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)
        loadingView.backgroundColor = UIColor.whiteColor()
        
        let loadingIcon = UIActivityIndicatorView()
        loadingIcon.frame.origin = CGPointMake(loadingView.frame.width/2, loadingView.frame.height/2)
        loadingIcon.color = UIColor.orangeColor()
        loadingView.addSubview(loadingIcon)
        view.addSubview(loadingView)
        
        loadingIcon.startAnimating()
        
    }
    
    // MARK: - Table view data source
    
    //make changes to the section header
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        //UIColor(red: 0/255, green: 181/255, blue: 229/255, alpha: 1.0) //make the background color light blue
        header.textLabel!.textColor = UIColor.lightGrayColor() //make the text white
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
        messageLabel.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.text = "Schedule for this Event has not been decided yet"
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.backgroundColor = UIColor.whiteColor()
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
                cell.backgroundColor = UIColor.lightGrayColor()
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


