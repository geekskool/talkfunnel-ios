//
//  ParticipantData.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 09/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

@objc(ParticipantData)
class ParticipantData: NSManagedObject {

    @NSManaged var company: String?
    @NSManaged var emailAddress: String?
    @NSManaged var mobileNumber: String?
    @NSManaged var name: String?
    @NSManaged var twitterHandle: String?
    @NSManaged var publicKey: String?
    @NSManaged var privateKey: String?
    @NSManaged var jobTitle: String?
    @NSManaged var participantDataUrl: String?
}
