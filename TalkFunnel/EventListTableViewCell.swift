//
//  EventListCellTableViewCell.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 10/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class EventListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    func setCell(event: EventList) {
        cardView.layer.cornerRadius = 10
        eventTitle.text = event.title
        eventDate.text = event.dateLocation
    }
}
