//
//  Slots.swift
//  Talk Funnel
//
//  Created by Jaison Titus on 03/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

class Slots {
    let time: String?
    var sessions = [Session]()
    
    init(data: NSDictionary) {
        self.time = data["slot"] as? String
        
        if let sessionList = data["sessions"] as? NSArray {
            for session in sessionList {
                if let dict = session as? NSDictionary {
                    let data = Session(data: dict)
                    sessions.append(data)
                }
            }
        }
    }
    
    
    init(data: SlotsData) {
        self.time = data.valueForKey("time") as? String
        
        if let sessionList = data.sessions?.allObjects as? [SessionData] {
            for session in sessionList {
                let data = Session(data: session)
                sessions.append(data)
            }
        }
    }
    
}