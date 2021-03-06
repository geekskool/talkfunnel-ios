//
//  EventList.swift
//  Talk Funnel
//
//  Created by Jaison Titus on 31/07/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

class EventList {
    let title: String?
    let year: String?
    let startDate: String?
    let endDate: String?
    let dateLocation: String?
    let website: String?
    let url: String?
    let jsonUrl: String?
    
    init(data: NSDictionary) {
        self.title = (data["title"] as? String)
        self.year = (data["name"] as? String)
        self.startDate = (data["start"] as? String)
        self.endDate = (data["end"] as? String)
        self.dateLocation = (data["datelocation"] as? String)
        self.website = (data["website"] as? String)
        self.url = (data["url"] as? String)
        self.jsonUrl = (data["json_url"] as? String)
    }
    
    init(data: NSManagedObject) {
        self.title = data.valueForKey("title") as? String
        self.year = data.valueForKey("year") as? String
        self.startDate = data.valueForKey("startDate") as? String
        self.endDate = data.valueForKey("endDate") as? String
        self.dateLocation = data.valueForKey("dateLocation") as? String
        self.website = data.valueForKey("website") as? String
        self.url = data.valueForKey("url") as? String
        self.jsonUrl = data.valueForKey("jsonUrl") as? String
    }
    
}