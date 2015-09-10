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
        selectTab(1)
        
    }
    
    func afterLogIn() {
        contactsVC.afterLogIn()
    }
    
    private func selectTab(tabNumber: Int) {
        self.selectedIndex = tabNumber
    }
}
