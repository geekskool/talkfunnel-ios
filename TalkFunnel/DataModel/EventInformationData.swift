//
//  EventInformationData.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 08/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

@objc(EventInformationData)
class EventInformationData: NSManagedObject {

    @NSManaged var rooms: NSSet?
    @NSManaged var schedules: NSSet?
    @NSManaged var venues: NSSet?
    
    func addRooms(rooms: RoomsData) {
        self.mutableSetValueForKey("rooms").addObject(rooms)
    }
    
    func addVenues(venues: VenuesData) {
        self.mutableSetValueForKey("venues").addObject(venues)
    }
    
    func addSchedules(schedules: ScheduleData) {
        self.mutableSetValueForKey("schedules").addObject(schedules)
    }
}
