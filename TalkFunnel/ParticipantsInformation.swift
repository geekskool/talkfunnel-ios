//
//  ParticipantsInformation.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 18/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation

class ParticipantsInformation {
    var company: String?
    var email: String?
    var twitter: String?
    var fullName: String?
    var jobTitle: String?
    var phoneNumber: String?
    var publicKey: String?
    
    init(participant: NSDictionary) {
        self.company = participant["company"] as? String
        self.email = participant["email"] as? String
        self.twitter = participant["twitter"] as? String
        self.fullName = participant["fullname"] as? String
        self.jobTitle = participant["job_title"] as? String
        self.phoneNumber = participant["phone"] as? String
        self.publicKey = participant["puk"] as? String
    }
    
}