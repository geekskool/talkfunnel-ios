//
//  Rooms.swift
//  Talk Funnel
//
//  Created by Jaison Titus on 05/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation

class Rooms {
    let name: String?
    let title: String?
    
    init(data: NSDictionary) {
        self.name = data["name"] as? String
        self.title = data["title"] as? String
    }
}