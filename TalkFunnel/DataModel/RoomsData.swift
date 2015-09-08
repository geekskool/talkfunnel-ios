//
//  RoomsData.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 08/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

@objc(RoomsData)
class RoomsData: NSManagedObject {

    @NSManaged var roomName: String?
    @NSManaged var roomTitle: String?
    @NSManaged var eventInformation: EventInformationData?
}
