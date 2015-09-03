//
//  LoadApplicationViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 12/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit


var pageController:DMDynamicViewController? = nil


let storyBoard = UIStoryboard(name: "Main",bundle: nil)
let contactsVC = storyBoard.instantiateViewControllerWithIdentifier("Contacts") as! ContactsViewController
let chatVC = storyBoard.instantiateViewControllerWithIdentifier("Chat") as UIViewController
let eventInfoVC = storyBoard.instantiateViewControllerWithIdentifier("EventInformation") as! EventInformationViewController
let eventListVC = storyBoard.instantiateViewControllerWithIdentifier("EventList") as UIViewController
let talksVC = storyBoard.instantiateViewControllerWithIdentifier("Talks") as! talkInfoScrollViewController


class LoadApplicationViewController: UIViewController,DMDynamicPageViewControllerDelegate,talkInforScrollViewControllerDelegate {
    
    var pageTitleLabel = UILabel()
    
    private var SCREENSIZE: CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMessageLabel()
        setUpApp()
    }
    
    private func setUpMessageLabel() {
        let messageLabel = UILabel()
        messageLabel.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.text = "Loading Data"
        messageLabel.textColor = UIColor.blackColor()
        view.addSubview(messageLabel)
        hideNavigationBar()
    }
    
    private func setUpApp() {
        getLocalData()
        fetchDataForEventList { (doneFetching,error) -> Void in
            if doneFetching {
                theEvent = currentEvent
                theEventInformation = currentEventInformation
                self.setUpPageView()
            }
            else {
                if error != nil {
                    self.noInternetConnection()
                }
            }
        }
    }
    
    private func setUpPageView() {
        setUpPageController()
        setUpNavigationBar()
    }
    
    private func setUpPageController() {
        //Add each of these view controllers to the Dynamic Page View Controller
        let viewControllers = [contactsVC,eventListVC,eventInfoVC,talksVC,chatVC]
        pageController = DMDynamicViewController(viewControllers: viewControllers)
        pageController?.view.frame = self.view.frame
        view.addSubview(pageController!.view)
        pageController?.delegate = self
        
    }
    
    private func setUpNavigationBar() {
        navigationController?.navigationBar.addSubview(pageTitleLabel)
        navigationController?.navigationBarHidden = false
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = UIColor.orangeColor()
    }
    
    private func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func noInternetConnection() {
        let noInternetConnectionAlert = UIAlertController(title: "Connection Error", message: "Unable to connect with server.Check your internet connection and try again", preferredStyle: UIAlertControllerStyle.Alert)
        let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.setUpApp()
        })
        noInternetConnectionAlert.addAction(tryAgainAction)
        self.presentViewController(noInternetConnectionAlert, animated: true, completion: nil)
    }
    
    //DMDynamic Page View controller Delegate Method
    func pageIsMoving(scrollView: UIScrollView, pageNumber: CGFloat) {
        setPageTitle(pageNumber)
        setPageTitleFrame()
        
        let value = 2*(pageNumber - floor(pageNumber))
        setPageTitleAlpha(value)
    }
    
    private func setPageTitle(pageNumber: CGFloat) {
        switch floor(pageNumber) {
        case 0:
            if isUserLoggedIn {
                pageTitleLabel.text = "SCAN CONTACT"
            }
            else {
                pageTitleLabel.text = "LOG IN"
            }
        case 1:
            pageTitleLabel.text = "EVENTS"
        case 2:
            pageTitleLabel.text = currentEvent?.title
        case 3:
            pageTitleLabel.text = "TALKS"
        case 4:
            pageTitleLabel.text = "CHAT"
        default:
            break
        }
    }
    
    private func setPageTitleFrame() {
        pageTitleLabel.font = UIFont(name: "Helvetica", size: 25)
        pageTitleLabel.textColor = UIColor.whiteColor()
        let vSize: CGSize = getLabelSize(pageTitleLabel)
        let originX = (self.SCREENSIZE.width/2.0 - vSize.width/2.0)
        pageTitleLabel.frame = CGRectMake(originX, 8, vSize.width, vSize.height)
    }
    
    private func getLabelSize(lbl: UILabel) -> CGSize{
        let txt = lbl.text!
        return txt.sizeWithAttributes([NSFontAttributeName: lbl.font])
    }
    
    private func setPageTitleAlpha(value: CGFloat) {
        var alpha: CGFloat
        if value > 1 {
            alpha = 2 - value
        }
        else {
            alpha = value
        }
        pageTitleLabel.alpha = alpha
    }
    
    
    func pageViewController(pageController: DMDynamicViewController, didSwitchToViewController viewController: UIViewController) {
        
    }
    
    func pageViewController(pageController: DMDynamicViewController, didChangeViewControllers viewControllers: Array<UIViewController>) {
        
    }
    
    //talkInforScrollViewControllerDelegate Method
    func talkScrolled() {
        pageController?.currentPage = 3
        hideNavigationBar()
    }
}
