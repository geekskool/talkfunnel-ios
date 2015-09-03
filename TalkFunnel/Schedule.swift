//
//  Schedule.swift
//  Talk Funnel
//
//  Created by Jaison Titus on 03/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation

class Schedule {
    
    let date: String?
    var slots = [Slots]()
    
    init(data: NSDictionary) {
        self.date = data["date"] as? String
        
        if let dailySlot = data["slots"] as? NSArray {
            for hourlySlot in dailySlot {
                if let dict = hourlySlot as? NSDictionary {
                    let data = Slots(data: dict)
                    slots.append(data)
                }
            }
        }
    }
    
}