//
//  talkInformationCell.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 03/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class TalkInformationCell: UITableViewCell {
    
    @IBOutlet weak var talkTitle: UILabel!
    @IBOutlet weak var speakerName: UILabel!
    @IBOutlet weak var talkTimings: UILabel!
    @IBOutlet weak var talkRoomName: UILabel!
    @IBOutlet weak var talkSectionType: UILabel!
    @IBOutlet weak var talkTechnicalLevel: UILabel!
    @IBOutlet weak var talkDescription: UILabel!
    @IBOutlet weak var speakerBio: UILabel!
    
    var talk: Session!
    
    func setUpCell(talkInfo: Session) {
        
        talk = talkInfo
        resetTextColorForAll()
        setTalkTitle()
        setSpeakerName()
        setTalkTimings()
        setTalkRoomName()
        setTalkSectionType()
        setTalkTechnicalLevel()
        setTalkDescription()
        setSpeakerBio()
    }
    
    private func resetTextColorForAll() {
        talkTitle.textColor = UIColor.orangeColor()
        speakerName.textColor = UIColor.blackColor()
        talkTimings.textColor = UIColor.blackColor()
        talkRoomName.textColor = UIColor.blackColor()
        talkSectionType.textColor = UIColor.blackColor()
        talkTechnicalLevel.textColor = UIColor.blackColor()
        talkDescription.textColor = UIColor.blackColor()
        speakerBio.textColor = UIColor.blackColor()
        
    }
    
    private func setTalkTitle() {
        talkTitle.text = talk.title
        talkTitle.numberOfLines = 0
        talkTitle.sizeToFit()
    }
    
    private func setSpeakerName() {
        if let speakerNameValue = talk.speakerName {
            speakerName.text = "by " + speakerNameValue
            if speakerNameValue == "" {
                speakerName.text = "Speaker Name Not Provided"
                speakerName.textColor = UIColor.lightGrayColor()
            }
        }
        else {
            speakerName.text = "Speaker Name Not Provided"
            speakerName.textColor = UIColor.lightGrayColor()
        }
    }
    
    private func setTalkTimings() {
        let startTime = getTimeFromDate(talk.startTime)
        let endTime = getTimeFromDate(talk.endTime)
        
        if startTime != "" || endTime != "" {
            talkTimings.text = "from " + startTime + " - " + endTime
        }
        else {
            talkTimings.text = "Talk Timings not Provided"
            talkTimings.textColor = UIColor.lightGrayColor()
        }
    }
    
    private func setTalkRoomName() {
        talkRoomName.text = getRoomName(talk.roomName)
    }
    
    private func setTalkSectionType() {
        if let talkSectionTypeValue = talk.sectionType {
            talkSectionType.text = "Section Type: " + talkSectionTypeValue
            if talkSectionTypeValue == "" {
                talkSectionType.text = "Section Type: Not Specified"
                talkSectionType.textColor = UIColor.lightGrayColor()
            }
        }
        else {
            talkSectionType.textColor = UIColor.lightGrayColor()
            talkSectionType.text = "Section Type: Not Specified"
        }
    }
    
    private func setTalkTechnicalLevel() {
        if let talkTechnicalLevelValue = talk.technicalLevel {
            talkTechnicalLevel.text = "Technical Level: " + talkTechnicalLevelValue
            if talkTechnicalLevelValue == "" {
                talkTechnicalLevel.text = "Technical Level: Not Specified"
                talkTechnicalLevel.textColor = UIColor.lightGrayColor()
            }
        }
        else {
            talkTechnicalLevel.text = "Technical Level: Not Specified"
            talkTechnicalLevel.textColor = UIColor.lightGrayColor()
        }
    }
    
    private func setTalkDescription() {
        if let talkDescriptionValue = talk.description {
            talkDescription.text = talkDescriptionValue
            if talkDescriptionValue == "" {
                talkDescription.text = "No talk description"
                talkDescription.textColor = UIColor.lightGrayColor()
            }
        }
        else {
            talkDescription.text = "No talk description"
            talkDescription.textColor = UIColor.lightGrayColor()
        }
        talkDescription.numberOfLines = 0
        talkDescription.sizeToFit()
    }
    
    private func setSpeakerBio() {
        if let speakerBioValue = talk.speakerBio {
            speakerBio.text = speakerBioValue
            if speakerBioValue == "" {
                speakerBio.text = "No Speaker Bio"
                speakerBio.textColor = UIColor.lightGrayColor()
            }
        }
        else {
            speakerBio.text = "No Speaker Bio"
            speakerBio.textColor = UIColor.lightGrayColor()
        }
        speakerBio.numberOfLines = 0
        speakerBio.sizeToFit()
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
    
    private func getRoomName(string: String?) -> String {
        if let givenRoomName = string {
            if let rooms = currentEventInformation?.roomNames {
                for room in rooms {
                    if let roomName = room.name {
                        if roomName == givenRoomName {
                            if let roomTitle = room.title {
                                return "at " + roomTitle
                            }
                        }
                    }
                }
            }
        }
        return ""
    }
    
    

}
