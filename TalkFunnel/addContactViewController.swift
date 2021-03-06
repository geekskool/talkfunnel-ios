//
//  addContactViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 01/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

protocol addContactViewControllerDelegate {
    func saveScannedContact()
}
class addContactViewController: UITableViewController {
    
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactCompanyName: UILabel!
    @IBOutlet weak var contactTwitterHandle: UILabel!
    @IBOutlet weak var contactPhoneNumber: UILabel!
    @IBOutlet weak var contactEmail: UILabel!
    
    var delegate :addContactViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPage()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpPage()
    }
    
    func setUpPage() {
        contactName.text = scannedParticipantInfo?.fullName
        contactCompanyName.text = scannedParticipantInfo?.company
        contactEmail.text = scannedParticipantInfo?.email
        contactPhoneNumber.text = scannedParticipantInfo?.phoneNumber
        contactTwitterHandle.text = scannedParticipantInfo?.twitter
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.delegate {
            delegate.saveScannedContact()
        }
    }
}

