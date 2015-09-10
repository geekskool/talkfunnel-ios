//
//  ProfileViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 10/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate {
    func logOutButtonClicked()
}
class ProfileViewController: UIViewController {

    var delegate: ProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        addLogOutScreen()
    }
    
    private func addLogOutScreen() {
        let logOutButton = UIButton()
        logOutButton.frame = CGRectMake(10, self.view.bounds.height * 0.4, self.view.bounds.width - 20, (self.view.bounds.height - 20) * 0.1)
        logOutButton.layer.cornerRadius = 10
        logOutButton.layer.borderColor = UIColor.orangeColor().CGColor
        logOutButton.setTitle("Log Out", forState: UIControlState.Normal)
        logOutButton.backgroundColor = UIColor.orangeColor()
        logOutButton.addTarget(self, action: "logOutButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(logOutButton)
    }
    
    func logOutButtonClicked(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.logOutButtonClicked()
        }
    }

}
