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
    @IBOutlet weak var button: UIButton!
    
    let savedContactsListVC = storyBoard.instantiateViewControllerWithIdentifier("SavedContactsList") as! SavedContactsListViewController
    let scanContactsVC = storyBoard.instantiateViewControllerWithIdentifier("ScanContact") as! ScanContactsViewController
    
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
        setButtonForPage()
    }
    
    private func setButtonForPage() {
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        if isUserLoggedIn {
            if isShowingSavedContactList {
                button.setImage(UIImage(named: "scanQR"), forState: UIControlState.Normal)
            }
            else {
                button.setImage(UIImage(named: "hasGeek"), forState: UIControlState.Normal)
            }
        }
        else {
            button.setImage(UIImage(named: "Login"), forState: UIControlState.Normal)
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
        
    }
    
    private func getMessageLabel(logInScreenView: UIView) -> UILabel {
        let messageLabel = UILabel()
        messageLabel.frame = logInScreenView.frame
        messageLabel.textAlignment = .Center
        messageLabel.text = "Please Log In to view or scan contacts"
        messageLabel.numberOfLines = 0
        messageLabel.backgroundColor = UIColor.whiteColor()
        return messageLabel
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
