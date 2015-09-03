//
//  talkInfoScrollViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 14/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class talkInfoScrollViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var talkCount = 0
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getBounds()
        getTalks()
    }
    
    func getTalks() {
        for scheduleForDay in schedule {
            for talk in scheduleForDay {
                if talk.isBreak! {
                    continue
                }
                addTalkToScrollView(talk)
            }
        }
        setUpScrollView()
    }
    
    func addTalkToScrollView(session: Session) {
        let talk = talkView(frame: CGRectMake(0, CGFloat(talkCount) * height, width, height))
        
        talk.talkTitle.text = session.title
        talk.talkTitle.numberOfLines = 0
        talk.talkTitle.font = UIFont(name: "Helvetica", size: 20)
        talk.talkTitle.sizeToFit()
        
        talk.speakerName.text = session.speakerName
        talk.timeAndDate.text = getTimeFromDate(session.startTime!)
        talk.roomAndVenue.text = session.roomName
        
        talk.talkDescription.text = session.description
        talk.talkDescription.sizeToFit()
        
        talk.speakerBio.text = session.speakerBio
        talk.speakerBio.sizeToFit()
        
        talk.sizeToFit()
        scrollView.addSubview(talk)
        talkCount++
    }
    
    func setUpScrollView() {
        scrollView!.contentSize = CGSizeMake(width, height * CGFloat(talkCount))
        
        //Set up and add scrollView to view
        scrollView.frame = self.view.frame
        self.scrollView.pagingEnabled = true
        self.scrollView.delegate = self
    }
    
    func refresh() {
        removeViewFromScrollView()
        self.talkCount = 0
        getTalks()
    }
    
    func removeViewFromScrollView() {
        for view in scrollView.subviews {
            if view is talkView {
                view.removeFromSuperview()
            }
        }
    }
    
    func scrollToSelectedTalk(selectedTalk: Session) {
        scrollView.contentOffset = findSelectedTalkPostion(selectedTalk)
    }
    
    func findSelectedTalkPostion(selectedTalk: Session) -> CGPoint {
        var talkNumber = 0
        var foundTalk = false
        for scheduleForDay in schedule {
            if foundTalk {
                break
            }
            for talk in scheduleForDay {
                if talk.isBreak! {
                    continue
                }
                if talk.title == selectedTalk.title {
                    foundTalk = true
                    break
                }
                talkNumber++
            }
        }
        return CGPoint(x: 0, y: height*CGFloat(talkNumber))
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let delegate = self.delegate {
            delegate.talkScrolled()
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
    
    func getDayFromDate(dateString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ" //iso 8601
        let date = dateFormatter.dateFromString(dateString)
        
        let newDateFormatter = NSDateFormatter()
        newDateFormatter.dateFormat = "yyyy-MM-dd"
        newDateFormatter.dateStyle = .MediumStyle
        return newDateFormatter.stringFromDate(date!)
    }

}


