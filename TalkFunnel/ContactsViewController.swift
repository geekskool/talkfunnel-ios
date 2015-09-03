//
//  ContactsViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 11/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, qrCodeScannerViewControllerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var instructionText: UILabel!
    @IBOutlet weak var logInOrOutButton: UIButton!
    
    let addContactVC = storyBoard.instantiateViewControllerWithIdentifier("addContact") as! addContactViewController
    var qrCodeScannerVC = storyBoard.instantiateViewControllerWithIdentifier("qrCodeScanner") as! qrCodeScannerViewController
    
    var isScanningComplete = false {
        willSet(newValue) {
            if newValue {
                changeButtonToSaveContact()
            }
            else {
                revertButtonBackToLogInOrLogOut()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addQRCodeScannerVC()
    }
    
    
    func addQRCodeScannerVC() {
        addChildViewController(qrCodeScannerVC)
        qrCodeScannerVC.view.frame = containerView.bounds
        containerView.addSubview(qrCodeScannerVC.view)
        qrCodeScannerVC.didMoveToParentViewController(self)
        qrCodeScannerVC.delegate = self
        qrCodeScannerVC.startReadingQRCode()
    }
    
    func removeQRCodeSCannerVC() {
        qrCodeScannerVC.willMoveToParentViewController(nil)
        qrCodeScannerVC.view.removeFromSuperview()
        qrCodeScannerVC.removeFromParentViewController()
    }
    
    func addAddContactVC() {
        addChildViewController(addContactVC)
        addContactVC.view.frame = containerView.bounds
        containerView.addSubview(addContactVC.view)
        addContactVC.didMoveToParentViewController(self)
    }
    
    func removeAddContactVC() {
        addContactVC.willMoveToParentViewController(nil)
        addContactVC.view.removeFromSuperview()
        addContactVC.removeFromParentViewController()
    }
    
    func refresh() {
        hasUserLoggedIn()
    }
    
    func changeButtonToSaveContact() {
        instructionText.text = "Scanned Contact Information "
        logInOrOutButton.setTitle("Save Contact", forState: UIControlState.Normal)
    }
    
    func revertButtonBackToLogInOrLogOut() {
        hasUserLoggedIn()
    }
    
    func hasUserLoggedIn() {
        if isUserLoggedIn {
            instructionText.text = "Point the camera at the QR Code to scan"
            logInOrOutButton.setTitle("Log out", forState: UIControlState.Normal)
        }
        else {
            instructionText.text = "Please Log In to scan badges"
            logInOrOutButton.setTitle("Log In", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func logInOrOut(sender: UIButton) {
        if isScanningComplete {
            saveScannedContact()
        }
        else {
            if isUserLoggedIn {
                logOut()
            }
            else {
                logIn()
            }
        }
    }
    
    
    func saveScannedContact() {
        let saveContact = SaveContactToAddressBook()
        saveContact.addContact()
        removeAddContactVC()
        addQRCodeScannerVC()
        isScanningComplete = false
    }
    
    func logOut() {
        userAccessToken = nil
        userTokenType = nil
        addToLocalData()
        isUserLoggedIn = false
        refresh()
    }
    
    
    func logIn() {
        if let url = NSURL(string:"http://auth.hasgeek.com/auth?client_id=eDnmYKApSSOCXonBXtyoDQ&scope=id+email+phone+organizations+teams+com.talkfunnel:*&response_type=token") {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
   
    
    //qrCodeScannerViewControllerDelegateMethod
    func doneScanningContactInfo() {
        removeQRCodeSCannerVC()
        addAddContactVC()
        isScanningComplete = true
    }
    
}
