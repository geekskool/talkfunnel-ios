//
//  SessionData.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 08/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

@objc(SessionData)
class SessionData: NSManagedObject {

    @NSManaged var endTime: String?
    @NSManaged var isBreak: NSNumber?
    @NSManaged var jsonUrl: String?
    @NSManaged var roomName: String?
    @NSManaged var sectionType: String?
    @NSManaged var speakerBio: String?
    @NSManaged var speakerName: String?
    @NSManaged var startTime: String?
    @NSManaged var talkDescription: String?
    @NSManaged var technicalLevel: String?
    @NSManaged var title: String?
    @NSManaged var slot: SlotsData?
}
