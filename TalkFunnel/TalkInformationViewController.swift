//
//  talkInformationViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 03/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import UIKit

class TalkInformationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var talks = [Session]()
    var loadingView = UIView()
    var messageLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTalks()
        //set the delegate and the datasource of the table view to be the instance of this class (UI View controller)
        tableView.delegate = self
        tableView.dataSource = self
        
        //To make the row height dynamic
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)

    }
    
    func refresh() {
        messageLabel.removeFromSuperview()
        loadingView.removeFromSuperview()
        getTalks()
        tableView.reloadData()
        resetTalksScroll()
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
    
    func scrollToSelectedTalk(talk: Session) {
        let indexPath = NSIndexPath(forRow: findTalk(talk), inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath,
            atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    
    //A fix to the weird layout issues, laying out the whole tableview so that the height doesnt mess up initially , basically scroll to the bottom
    func resetTalksScroll() {
        if talks.count > 0 {
            scrollToTalk(talks.count - 1)
            scrollToTalk(0)
        }
    }
    
    func scrollToTalk(talkNumber: Int) {
        let indexPath = NSIndexPath(forRow: talkNumber, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    private func findTalk(talk: Session) -> Int {
        var talkNumber = 0
        
        for t in talks {
            if let talkTitle = t.title {
                if talkTitle == talk.title! {
                    return talkNumber
                }
            }
            talkNumber++
        }
        return talkNumber
    }
    
    private func getTalks() {
        talks.removeAll()
        for schedulePerDay in schedule {
            for talk in schedulePerDay {
                if talk.isBreak! {
                    continue
                }
                talks.append(talk)
            }
        }
    }
    
    //TableView Datasource Methods
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = talks.count
        if count == 0 {
            addMessageLabel()
        }
        return count
    }
    
    private func addMessageLabel() {
        messageLabel.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.text = "Talks for this Event has not been decided yet"
        messageLabel.textColor = UIColor.grayColor()
        messageLabel.numberOfLines = 0
        messageLabel.backgroundColor = UIColor.clearColor()
        messageLabel.font = UIFont(name: "Helvetica", size: 25)
        view.addSubview(messageLabel)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let talkInformationCell = tableView.dequeueReusableCellWithIdentifier("talkInformation", forIndexPath: indexPath) as! TalkInformationCell
        
        let talk = talks[indexPath.row]
        talkInformationCell.setUpCell(talk)
        
        return talkInformationCell
    }
}
