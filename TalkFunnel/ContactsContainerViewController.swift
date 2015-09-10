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
class ContactsContainerViewController: UIViewController,DMDynamicPageViewControllerDelegate,SavedContactsListViewControllerDelegate,ProfileViewControllerDelegate {
    
    let savedContactsListVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("SavedContactsList") as! SavedContactsListViewController
    let scanContactsVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("ScanContact") as! ScanContactsViewController
    let profileVC = ProfileViewController()
    
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
        }
        doneRefreshingSavedContactList()
    }
    
    private func doneRefreshingSavedContactList() {
        savedContactsListVC.refreshControl.endRefreshing()
        savedContactsListVC.refresh()
    }
}
