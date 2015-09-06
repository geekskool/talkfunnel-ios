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
    
    func setData(contact: NSManagedObject) {
        contactCellBackground.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 255/255, alpha: 1)
        contactCellBackground.layer.cornerRadius = 8
        contactName.text = contact.valueForKey("name") as? String
        contactCompanyName.text = contact.valueForKey("company") as? String
        contactPhoneNumber.text = contact.valueForKey("mobileNumber") as? String
        contactEmail.text = contact.valueForKey("emailAddress") as? String
        contactTwitterHandle.text = contact.valueForKey("twitterHandle") as? String
    }

}
