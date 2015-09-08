//
//  Contacts.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 08/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import CoreData

@objc(Contacts)
class Contacts: NSManagedObject {
    @NSManaged var company: String?
    @NSManaged var emailAddress: String?
    @NSManaged var mobileNumber: String?
    @NSManaged var name: String?
    @NSManaged var twitterHandle: String?
}
