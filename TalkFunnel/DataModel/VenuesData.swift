//
//  VenuesData.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 08/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

@objc(VenuesData)
class VenuesData: NSManagedObject {

    @NSManaged var venueName: String?
    @NSManaged var eventInformation: EventInformationData?
}
