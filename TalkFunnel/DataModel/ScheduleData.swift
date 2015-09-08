//
//  ScheduleData.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 08/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

@objc(ScheduleData)
class ScheduleData: NSManagedObject {

    @NSManaged var date: String?
    @NSManaged var eventInformation: EventInformationData?
    @NSManaged var slots: NSSet?
    
    func addSlots(slot: SlotsData) {
        self.mutableSetValueForKey("slots").addObject(slot)
    }
}
