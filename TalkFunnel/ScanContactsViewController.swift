//
//  ContactsViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 11/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit
import CoreData

class ScanContactsViewController: UIViewController, addContactViewControllerDelegate, qrCodeScannerViewControllerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var instructionText: UILabel!
    
    let addContactVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("addContact") as! addContactViewController
    var qrCodeScannerVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("qrCodeScanner") as! qrCodeScannerViewController
    
    var isScanningComplete = false {
        willSet(newValue) {
            if newValue {
                setUpPageToSaveContact()
            }
            else {
                setUpPageToScan()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addContactVC.delegate = self
        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addQRCodeScannerVC()
    }
    
    func refresh() {
        setUpPageToScan()
    }
    
    func setUpPageToScan() {
        instructionText.text = "Point the camera at the QR Code to scan"
    }
    
    func setUpPageToSaveContact() {
        instructionText.text = "Scanned Contact Information"
    }
    
    func addQRCodeScannerVC() {
        addViewControllerToContainerView(qrCodeScannerVC)
        qrCodeScannerVC.delegate = self
        qrCodeScannerVC.startReadingQRCode()
    }
    
    func removeQRCodeScannerVC() {
        removeViewControllerFromContainerView(qrCodeScannerVC)
    }
    
    func addAddContactVC() {
        addViewControllerToContainerView(addContactVC)
    }
    
    func removeAddContactVC() {
        removeViewControllerFromContainerView(addContactVC)
    }
    
    //MARK: addcontactViewcontrollerDelegate Method
    func saveScannedContact() {
        if checkIfContactAlreadyExists() {
            showContactExistsAlert()
        }
        else {
            saveDataToDevice()
        }
    }
    
    private func showContactExistsAlert() {
        let contactExistsAlert = UIAlertController(title: "Contact Exists", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            self.removeAddContactVC()
            self.addQRCodeScannerVC()
            self.isScanningComplete = false
        })
        contactExistsAlert.addAction(cancelAction)
        self.presentViewController(contactExistsAlert, animated: true, completion: nil)
        
    }
    
    private func checkIfContactAlreadyExists() -> Bool {
        for contact in savedContacts {
            if contact.privateKey == scannedParticipantInfo?.privateKey {
                return true
            }
        }
        return false
    }
    
    private func saveDataToDevice() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Contacts")
        fetchRequest.predicate = NSPredicate(format: "publicKey = %@", (scannedParticipantInfo?.publicKey)!)
        
        let fetchedResults: [ParticipantData]?
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [ParticipantData]
            if let results = fetchedResults {
                for contact in results {
                    contact.privateKey = scannedParticipantInfo?.privateKey
                    let data  = ParticipantsInformation(participant: contact)
                    savedContacts.append(data)
                }
                do {
                    try managedContext.save()
                }
                catch {
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
        catch {
            //error
        }
        removeAddContactVC()
        addQRCodeScannerVC()
        isScanningComplete = false
    }
    
    
    private func addViewControllerToContainerView(viewController: UIViewController) {
        addChildViewController(viewController)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
    }
    
    private func removeViewControllerFromContainerView(viewController: UIViewController) {
        viewController.willMoveToParentViewController(nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    
    //MARK: qrCodeScannerViewControllerDelegateMethod
    func doneScanningContactInfo() {
        removeQRCodeScannerVC()
        addAddContactVC()
        isScanningComplete = true
    }
    
}
