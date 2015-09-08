//
//  EventInformation.swift
//  Talk Funnel
//
//  Created by Jaison Titus on 03/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

class EventInformation {
    
    var roomNames = [Rooms]()
    var venueNames = [String]()
    var schedule =  [Schedule]()
    
    init(data: NSDictionary) {
        
        if let rooms = data["rooms"] as? NSArray {
            for room in rooms {
                if let dict = room as? NSDictionary {
                    let data = Rooms(data: dict)
                        roomNames.append(data)
                }
            }
        }
        
        if let venues = data["venues"] as? NSArray {
            for venue in venues {
                venueNames.append(venue["title"] as! String)
            }
        }
        
        if let completeSchedule = data["schedule"] as? NSArray {
            for dailySchedule in completeSchedule {
                if let dict = dailySchedule as? NSDictionary {
                    let data = Schedule(data: dict)
                    schedule.append(data)
                }
            }
        }
        
    }
    
    init(data : EventInformationData) {
        
        if let rooms = data.rooms?.allObjects as? [RoomsData] {
            for room in rooms {
                let data = Rooms(data: room)
                roomNames.append(data)
            }
        }
        
        if let venues = data.venues?.allObjects as? [VenuesData] {
            for venue in venues {
                if let data = venue.valueForKey("venueName") as? String {
                    venueNames.append(data)
                }
            }
        }
        
        if let completeSchedule = data.schedules?.allObjects as? [ScheduleData] {
            for dailySchedule in completeSchedule {
                let data = Schedule(data: dailySchedule)
                schedule.append(data)
            }
        }
    }
    
}
