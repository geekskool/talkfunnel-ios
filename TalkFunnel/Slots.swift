//
//  Slots.swift
//  Talk Funnel
//
//  Created by Jaison Titus on 03/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation

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
    
}