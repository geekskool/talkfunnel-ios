//
//  ContactsContainerViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 10/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

protocol ContactsContainerViewControllerDelegate {
    func pageChanged(pageNumber: CGFloat)
    func loggedOut()
}
class ContactsContainerViewController: UIViewController,DMDynamicPageViewControllerDelegate,SavedContactsListViewControllerDelegate,ProfileViewControllerDelegate,ScanContactsViewControllerDelegate,SaveContactToAddressBookDelegate {
    
    let savedContactsListVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("SavedContactsList") as! SavedContactsListViewController
    let scanContactsVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("ScanContact") as! ScanContactsViewController
    let profileVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("Profile") as! ProfileViewController
    
    var pageController:DMDynamicViewController? = nil
    var delegate: ContactsContainerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVC()
    }
    
    func setUpVC() {
        setUpPageController()
        setUpNavigationBar()
        setUpDelegates()
        
    }
    private func setUpDelegates() {
        savedContactsListVC.delegate = self
        profileVC.delegate = self
        pageController?.delegate = self
        scanContactsVC.delegate = self
        savedContactsListVC.saveContactToAB.delegate = self
    }
    private func setUpPageController() {
        //Add each of these view controllers to the Dynamic Page View Controller
        let viewControllers = [savedContactsListVC,scanContactsVC,profileVC]
        pageController = DMDynamicViewController(viewControllers: viewControllers)
        pageController?.view.frame = self.view.frame
        pageController?.currentPage = 0
        view.addSubview((pageController?.view)!)
    }
    
    
    private func setUpNavigationBar() {
        navigationController?.navigationBar.translucent = false
    }
    
    
    //MARK: DMDynamicPageViewControllerDelegate Methods
    func pageViewController(pageController: DMDynamicViewController, didSwitchToViewController viewController: UIViewController) {
        
    }
    func pageViewController(pageController: DMDynamicViewController, didChangeViewControllers viewControllers: Array<UIViewController>) {
        
    }
    
    func pageIsMoving(pageNumber: CGFloat) {
        if let delegate = self.delegate {
            delegate.pageChanged(pageNumber)
        }
    }
    
    //ProfileViewControllerDelegate Method
    func logOutButtonClicked() {
        logOut()
    }
    
    //MARK: LogOut
    private func logOut() {
        userAccessToken = nil
        userTokenType = nil
        addToLocalData()
        isUserLoggedIn = false
        if let delegate = self.delegate {
            delegate.loggedOut()
        }
    }
    
    //MARK: SavedContactsListViewControllerDelegate Method
    func triedToRefreshContactList(done: Bool) {
        if done {
            saveFetchedParticipantData()
            doneRefreshingSavedContactList()
        }
        else {
            showAlert("Refresh Failed", message: "Please check your internet connection and try again", callback: { (done) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.doneRefreshingSavedContactList()
                })
            })
        }
    }
    
    private func doneRefreshingSavedContactList() {
        savedContactsListVC.refreshControl.endRefreshing()
        savedContactsListVC.isRefreshing = false
        savedContactsListVC.refresh()
    }
    
    private func showAlert(title: String,message: String,callback: Bool -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            callback(true)
        })
        alert.addAction(dismiss)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: ScanContactsViewControllerDelegate Method
    func showContactExistsAlert(callBack: Bool -> Void) {
        let contactExistsAlert = UIAlertController(title: "Contact Exists", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            callBack(true)
        })
        contactExistsAlert.addAction(cancelAction)
        self.presentViewController(contactExistsAlert, animated: true, completion: nil)
    }
    
    func noAccessToCamera() {
        showAlert("Denied access to camera", message: "Please go to the phone settings and allow TalkFunnel to access the camera to scan badges") { (done) -> Void in
        }
    }
    
    func askToSaveContact(callback: Bool -> Void) {
        let alert = UIAlertController(title: "Save Contact", message: "Do you wish to save the contact", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let save = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) { (action) -> Void in
            callback(true)
        }
        let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            callback(false)
        }
        alert.addAction(cancel)
        alert.addAction(save)
        alert.addAction(delete)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func justScannedAndSavedNewContact() {
        savedContactsListVC.refresh()
    }
    
    //MARK: SaveContactsToAddressBookDelegate Method
    func savingFailed() {
        showAlert("Failed", message: "Failed to save contact") { (done) -> Void in
            
        }
    }
    
    func savingSuccessfull() {
        showAlert("Successful", message: "Saved contact to address book") { (done) -> Void in
            
        }
    }
    
    func nothingToSave() {
        showAlert("Error", message: "Apparently there was nothing to save") { (done) -> Void in
            
        }
    }
    
    func noAccessGranted() {
        showAlert("Denied Address book access", message: "Please go to phone settings and allow TalkFunnel to access Contacts") { (done) -> Void in
            
        }
    }
    
}
