//
//  ContactsViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 06/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    let savedContactsListVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("SavedContactsList") as! SavedContactsListViewController
    let scanContactsVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("ScanContact") as! ScanContactsViewController
    
    var isShowingSavedContactList = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    func refresh() {
        if isUserLoggedIn {
            addViewControllerToContainerView(savedContactsListVC)
        }
        else {
            addLogInScreen()
        }
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
    
    private func addLogInScreen() {
        let logInScreenView = UIView()
        logInScreenView.frame = containerView.bounds
        containerView.addSubview(logInScreenView)
        logInScreenView.addSubview(getMessageLabel(logInScreenView))
        logInScreenView.addSubview(addLogInButton(logInScreenView))
        
    }
    
    private func getMessageLabel(logInScreenView: UIView) -> UILabel {
        let messageLabel = UILabel()
        messageLabel.frame = CGRectMake(10, 10, logInScreenView.frame.width - 20, logInScreenView.frame.height * 0.5)
        messageLabel.textAlignment = .Center
        messageLabel.text = "Please Log In to view or scan contacts"
        messageLabel.numberOfLines = 0
        messageLabel.backgroundColor = UIColor.whiteColor()
        messageLabel.textColor = UIColor.lightGrayColor()
        return messageLabel
    }
    
    private func addLogInButton(logInScreenView: UIView) -> UIButton {
        let logInButton = UIButton()
        logInButton.frame = CGRectMake(10, logInScreenView.frame.height * 0.5, logInScreenView.frame.width - 20, logInScreenView.frame.height * 0.1)
        logInButton.layer.cornerRadius = 10
        logInButton.layer.borderColor = UIColor.orangeColor().CGColor
        logInButton.setTitle("Log In", forState: UIControlState.Normal)
        logInButton.backgroundColor = UIColor.orangeColor()
        logInButton.addTarget(self, action: "logInButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        return logInButton
    }
    
    func logInButtonClicked(sender: UIButton) {
        logIn()
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
        if isUserLoggedIn {
            if isShowingSavedContactList {
                removeViewControllerFromContainerView(savedContactsListVC)
                addViewControllerToContainerView(scanContactsVC)
                isShowingSavedContactList = false
            }
            else {
                removeViewControllerFromContainerView(scanContactsVC)
                addViewControllerToContainerView(savedContactsListVC)
                isShowingSavedContactList = true
            }
        }
        else {
            logIn()
        }
    }
    
    
    func logIn() {
        if let url = NSURL(string:"http://auth.hasgeek.com/auth?client_id=eDnmYKApSSOCXonBXtyoDQ&scope=id+email+phone+organizations+teams+com.talkfunnel:*&response_type=token") {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
}
