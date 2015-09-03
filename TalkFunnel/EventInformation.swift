//
//  EventInformation.swift
//  Talk Funnel
//
//  Created by Jaison Titus on 03/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation

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
    
    
    
    
}
