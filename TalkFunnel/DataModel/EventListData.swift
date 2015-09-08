//
//  EventListData.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 08/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

@objc(EventListData)
class EventListData: NSManagedObject {
    @NSManaged var dateLocation: String?
    @NSManaged var endDate: String?
    @NSManaged var jsonUrl: String?
    @NSManaged var startDate: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var website: String?
    @NSManaged var year: String?
}
