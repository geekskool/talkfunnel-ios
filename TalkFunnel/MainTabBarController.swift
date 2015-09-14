//
//  MainTabBarController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 09/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    let contactsVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("Contacts") as! ContactsViewController
    let chatVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("Chat") as! ChatViewController
    let eventsVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("MainEventsNav") as! UINavigationController
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setUpVC()
    }
    
    func setUpVC() {        
        contactsVC.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Contacts, tag: 0)
        var image = UIImage(named: "Funnel")
        image = image?.imageWithRenderingMode(.AlwaysTemplate)
        eventsVC.tabBarItem = UITabBarItem(title: "Event", image: image, tag: 0)
        var image2 = UIImage(named: "Chat")
        image2 = image2?.imageWithRenderingMode(.AlwaysTemplate)
        chatVC.tabBarItem = UITabBarItem(title: "Chat", image: image2, tag: 0)
        self.viewControllers = [contactsVC,eventsVC,chatVC]
        if isUserLoggedIn {
            selectTab(1)
        }
        else {
            selectTab(0)
        }
        
    }
    
    func afterLogIn() {
        contactsVC.afterLogIn()
    }
    
    private func selectTab(tabNumber: Int) {
        self.selectedIndex = tabNumber
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.title != nil {
            contactsVC.contactsContainerVC.scanContactsVC.qrCodeScannerVC.stopRunning()
        }
        else {
            contactsVC.contactsContainerVC.scanContactsVC.qrCodeScannerVC.startRunning()
        }
    }
    
    func accessDeniedAfterLogIn() {
        let alert = UIAlertController(title: "Access Denied", message: "You did not authorize Talkfunnel after logging in", preferredStyle: UIAlertControllerStyle.Alert)
        let tryAgainAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        })
        alert.addAction(tryAgainAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
