//
//  addContactViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 01/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class addContactViewController: UITableViewController {
    
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactCompanyName: UILabel!
    @IBOutlet weak var contactTwitterHandle: UILabel!
    @IBOutlet weak var contactPhoneNumber: UILabel!
    @IBOutlet weak var contactEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPage()
    }
    
    func setUpPage() {
        contactName.text = scannedParticipantInfo?.fullName
        contactCompanyName.text = scannedParticipantInfo?.company
        contactEmail.text = scannedParticipantInfo?.email
        contactPhoneNumber.text = scannedParticipantInfo?.phoneNumber
        contactTwitterHandle.text = scannedParticipantInfo?.twitter
    }
}

