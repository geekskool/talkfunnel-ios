//
//  ContactTableViewCell.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 06/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit
import CoreData

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var contactCellBackground: UIView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactCompanyName: UILabel!
    @IBOutlet weak var contactPhoneNumber: UILabel!
    @IBOutlet weak var contactEmail: UILabel!
    @IBOutlet weak var contactTwitterHandle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData(contact: ParticipantsInformation) {
        messageLabel.layer.cornerRadius = 8
        contactName.text = contact.fullName
        contactCompanyName.text = contact.company
        contactPhoneNumber.text = contact.phoneNumber
        contactEmail.text = contact.email
        contactTwitterHandle.text = contact.twitter
        
        if contact.phoneNumber == nil {
            contactPhoneNumber.textColor = UIColor.lightGrayColor()
            contactPhoneNumber.text = "No mobile number , pull down to fetch"
        }
        if contact.twitter == "" {
            contactTwitterHandle.textColor = UIColor.lightGrayColor()
            contactTwitterHandle.text = "No twitter handle"
        }
    }

}
