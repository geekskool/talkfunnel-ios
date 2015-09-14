//
//  Sessions.swift
//  Talk Funnel
//
//  Created by Jaison Titus on 03/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

class Session {
    
    let title: String?
    let description: String?
    let isBreak: Bool?
    let roomName: String?
    let jsonUrl: String?
    let speakerName: String?
    let speakerBio: String?
    let technicalLevel: String? // Beginner , Intermediate or Expert
    let sectionType: String? //Full talk, keynote , workshop etc
    let startTime: String?
    let endTime: String?
    
    init(data: NSDictionary) {
        self.title = data["title"] as? String
        self.description = data["description_text"] as? String
        self.isBreak = data["is_break"] as? Bool
        self.jsonUrl = data["json_url"] as? String
        self.roomName = data["room"] as? String
        self.speakerName = data["speaker"] as? String
        self.speakerBio = data["speaker_bio_text"] as? String
        self.technicalLevel = data["technical_level"] as? String
        self.sectionType = data["section_title"] as? String
        self.startTime = data["start"] as? String
        self.endTime = data["end"] as? String
    }
    
    init(data: SessionData) {
        self.title = data.title
        self.description = data.talkDescription
        if data.isBreak == 1 {
            self.isBreak = true
        }
        else {
            self.isBreak = false
        }
        self.jsonUrl = data.jsonUrl
        self.roomName = data.roomName
        self.speakerName = data.speakerName
        self.speakerBio = data.speakerBio
        self.technicalLevel = data.technicalLevel
        self.sectionType = data.sectionType
        self.startTime = data.startTime
        self.endTime = data.endTime
    }
}