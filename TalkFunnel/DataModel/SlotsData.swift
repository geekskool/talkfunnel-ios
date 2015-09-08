//
//  SlotsData.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 08/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

@objc(SlotsData)
class SlotsData: NSManagedObject {

    @NSManaged var time: String?
    @NSManaged var schedule: ScheduleData?
    @NSManaged var sessions: NSSet?
    
    func addSessions(session: SessionData) {
        self.mutableSetValueForKey("sessions").addObject(session)
    }
}
