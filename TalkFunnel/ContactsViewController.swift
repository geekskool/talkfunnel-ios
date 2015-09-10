//
//  ContactsViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 06/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController,ContactsContainerViewControllerDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    let contactsContainerVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("ContactsContainer") as! ContactsContainerViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegates()
    }
    
    private func setUpDelegates() {
        contactsContainerVC.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            contactsContainerVC.pageController?.moveToPage(0)
        case 1:
            contactsContainerVC.pageController?.moveToPage(1)
        case 2:
            contactsContainerVC.pageController?.moveToPage(2)
        default:
            break; 
        }
    }
    
    func refresh() {
        if isUserLoggedIn {
            addViewControllerToContainerView(contactsContainerVC)
        }
        else {
            removeViewControllerFromContainerView(contactsContainerVC)
            addLogInScreen()
        }
    }
    
    func refreshAfterLogIn() {
        let spinner = UIActivityIndicatorView()
        spinner.frame = CGRectMake(0, 0, containerView.bounds.width, containerView.bounds.height)
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        spinner.backgroundColor = UIColor.whiteColor()
        containerView.addSubview(spinner)
        
        let messageView = UIView()
        messageView.frame = CGRectMake(0, 0, containerView.bounds.width, containerView.bounds.height/3)
        containerView.addSubview(getMessageLabel(messageView, message: "Please Wait"))
        spinner.startAnimating()
        
    }
    
    func afterLogIn() {
        refreshAfterLogIn()
        segmentedControl.selectedSegmentIndex = 0
        contactsContainerVC.pageController?.moveToPage(0)
        contactsContainerVC.savedContactsListVC.fetchParticipantListFromServer { (done) -> Void in
            self.refresh()
            
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
        logInScreenView.addSubview(getMessageLabel(logInScreenView,message: "Log in to view or scan contacts"))
        logInScreenView.addSubview(addLogInButton(logInScreenView))
        
    }
    
    private func getMessageLabel(logInScreenView: UIView,message: String) -> UILabel {
        let messageLabel = UILabel()
        messageLabel.frame = CGRectMake(10, 10, logInScreenView.bounds.width - 20, logInScreenView.bounds.height * 0.5)
        messageLabel.textAlignment = .Center
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.backgroundColor = UIColor.whiteColor()
        messageLabel.textColor = UIColor.lightGrayColor()
        return messageLabel
    }
    
    private func addLogInButton(logInScreenView: UIView) -> UIButton {
        let logInButton = UIButton()
        logInButton.frame = CGRectMake(10, logInScreenView.bounds.height * 0.5, logInScreenView.bounds.width - 20, logInScreenView.frame.height * 0.1)
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
    
    func logIn() {
        if let url = NSURL(string:"http://auth.hasgeek.com/auth?client_id=eDnmYKApSSOCXonBXtyoDQ&scope=id+email+phone+organizations+teams+com.talkfunnel:*&response_type=token") {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    //MARK: ContactsContainerViewControllerDelegate Method 
    func pageChanged(pageNumber: CGFloat) {
        if pageNumber < 1.0 {
            segmentedControl.selectedSegmentIndex = 0
        }
        if pageNumber < 2.0 && pageNumber > 1.0 {
            segmentedControl.selectedSegmentIndex = 1

        }
        if pageNumber < 3.0 && pageNumber > 2.0 {
            segmentedControl.selectedSegmentIndex = 2

        }
    }
    
    func loggedOut() {
        self.refresh()
    }
    
    
}
