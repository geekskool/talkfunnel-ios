 //
//  ScheduleTableViewCell.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 11/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

    
    @IBOutlet weak var speakerName: UILabel!
    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var talkTiming: UILabel!
    @IBOutlet weak var talkTitle: UILabel!
    //once the value of slots is set , do the following
    var session: Session? {
        didSet {
            if let talk = session {
                talkTiming.text = getTimeFromDate(talk.startTime)
                talkTitle.text = talk.title
                speakerName.text = talk.speakerName
                roomName.text = getRoomName(talk.roomName)
            }
        }
    }
    
    private func getRoomName(string: String?) -> String {
        if let roomString = string {
            if let eventInfo = currentEventInformation {
                let rooms = eventInfo.roomNames
                for room in rooms {
                    if room.name == roomString {
                        return room.title!
                    }
                }
            }
        }
        return ""
    }
    
    
    private func getTimeFromDate(string: String?) -> String {
        if let dateString = string {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ" //iso 8601
            let date = dateFormatter.dateFromString(dateString)
            
            let newDateFormatter = NSDateFormatter()
            newDateFormatter.dateFormat = "HH:mm" // 08:30
            return newDateFormatter.stringFromDate(date!)
        }
        return ""
    }
    
}
