//
//  EventsViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 09/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController,DMDynamicPageViewControllerDelegate,EventListViewControllerDelegate,EventInformationViewControllerDelegate,UINavigationBarDelegate {

    
    @IBOutlet weak var backArrowButton: UIBarButtonItem!
    @IBOutlet weak var nextArrowButton: UIBarButtonItem!
    
    var pageTitleLabel = UILabel()
    var currentPageNumber: CGFloat = 1.0
    var pageController:DMDynamicViewController? = nil
    private var SCREENSIZE: CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    
    let eventInfoVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("EventInformation") as! EventInformationViewController
    let eventListVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("EventList") as! EventListViewController
    let talksVC = UIStoryboard(name: "Main",bundle: nil).instantiateViewControllerWithIdentifier("Talks") as! TalkInformationViewController
    
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
        eventListVC.delegate = self
        eventInfoVC.delegate = self
        pageController?.delegate = self
    }
    private func setUpPageController() {
        //Add each of these view controllers to the Dynamic Page View Controller
        let viewControllers = [eventListVC,eventInfoVC,talksVC]
        pageController = DMDynamicViewController(viewControllers: viewControllers)
        pageController?.view.frame = self.view.frame
        talksVC.resetTalksScroll()
        view.addSubview((pageController?.view)!)
    }
    
    
    private func setUpNavigationBar() {
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.addSubview(pageTitleLabel)
    }
    
    @IBAction func backButtonClicked(sender: UIBarButtonItem) {
        if currentPageNumber != 0 {
            if currentPageNumber == 1 {
                sender.tintColor = UIColor.clearColor()
            }
            if currentPageNumber == 2 {
                nextArrowButton.tintColor = UIColor.orangeColor()
            }
            currentPageNumber--
        }
        pageController?.moveToPage(currentPageNumber)
    }
    @IBAction func nextButtonClicked(sender: UIBarButtonItem) {
        if currentPageNumber != 2 {
            if currentPageNumber == 1 {
                sender.tintColor = UIColor.clearColor()
            }
            if currentPageNumber == 0 {
                backArrowButton.tintColor = UIColor.orangeColor()
            }
            currentPageNumber++
        }
        pageController?.moveToPage(currentPageNumber)
    }

    //MARK: EventListViewControllerDelegate Method
    func didSelectEvent(event: EventList) {
        if let currentEventDetail = currentEvent {
            let tempEvent = currentEvent
            currentEvent = event
            pageController?.moveToPage(1)
            currentPageNumber = 1
            if currentEventDetail.title! == event.title && currentEventDetail.jsonUrl! == event.jsonUrl {
                eventListVC.didFinishLoadingNewEvent()
                eventInfoVC.refresh()
                talksVC.refresh()
            }
            else {
                eventInfoVC.addLoadingDataView()
                talksVC.addLoadingDataView()
                fetchDataForEvent { (doneFetching,error) -> Void in
                    if doneFetching {
                        fetchParticipantRelatedData("participants/json", callback: { (done, error) -> Void in
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if done {
                                    self.moveToNewEvent()
                                }
                                else {
                                    if isUserLoggedIn {
                                        self.noInternetAlert({ (dismiss) -> Void in
                                            if dismiss {
                                                self.moveToPreviousEvent(tempEvent)
                                            }
                                        })
                                    }
                                    else {
                                        self.moveToNewEvent()
                                    }
                                    
                                }
                            })
                        })
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.noInternetAlert({ (dismiss) -> Void in
                                if dismiss {
                                    self.moveToPreviousEvent(tempEvent)
                                }
                            })
                        })
                    }
                }
            }
        }
    }
    
    func moveToNewEvent() {
        currentEventTitle = currentEvent?.title
        addToLocalData()
        self.pageController?.moveToPage(1)
        self.currentPageNumber = 1
        refreshVCs()
    }
    
    func moveToPreviousEvent(tempEvent: EventList?) {
        self.pageController?.moveToPage(0)
        self.currentPageNumber = 0
        currentEvent = tempEvent
        refreshVCs()
    }
    
    func refreshVCs() {
        self.eventListVC.didFinishLoadingNewEvent()
        self.eventInfoVC.refresh()
        self.talksVC.refresh()
    }
    
    func triedToRefreshEventList(done: Bool) {
        eventListVC.refreshControl.endRefreshing()
        eventListVC.isRefreshing = false
        reactToRefresh(done)
    }
    
    func showStillLoadingClickedEventAlert() {
        var message = "The internet connection appears to be slow , please wait until the previously clicked event has finished loading"
        if let eventName = currentEvent?.title {
            message = "The internet connection appears to be slow , please wait until \(eventName) has finished loading"
        }
        let alert = UIAlertController(title: "Patience", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        })
        alert.addAction(dismiss)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Alert
    func noInternetAlert(callBack: Bool -> Void) {
        let alert = UIAlertController(title: "No Internet", message: "Please connect to the internet and retry", preferredStyle: UIAlertControllerStyle.Alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            callBack(true)
        })
        alert.addAction(dismiss)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: EventInformationViewControllerDelegate Method
    func didSelectTalk(talk: Session) {
        pageController?.moveToPage(2)
        currentPageNumber = 2
        talksVC.scrollToSelectedTalk(talk)
    }
    
    func triedToRefreshEventInfo(done: Bool) {
        eventInfoVC.refreshControl.endRefreshing()
        eventInfoVC.isRefreshing = false
        reactToRefresh(done)
    }
    
    //MARK: DMDynamicPageViewControllerDelegate Methods
    func pageViewController(pageController: DMDynamicViewController, didSwitchToViewController viewController: UIViewController) {
        
    }
    func pageViewController(pageController: DMDynamicViewController, didChangeViewControllers viewControllers: Array<UIViewController>) {
        
    }
    
    func pageIsMoving(pageNumber: CGFloat) {
        let value = 2*(pageNumber - floor(pageNumber))
        let alpha = getAlpha(value)
        
        currentPageNumber = floor(pageNumber)
        setPageTitle(pageNumber)
        setPageTitleFrame()
        setPageTitleAlpha(alpha)
        setBarButtonAlpha(pageNumber)
        
    }

    private func getAlpha(value: CGFloat) -> CGFloat {
        var alpha: CGFloat
        if value > 1 {
            alpha = 2 - value
        }
        else {
            alpha = value
        }
        return alpha
    }
    
    //MARK: Methods for Views inside NavigationBar
    private func setPageTitle(pageNumber: CGFloat) {
        switch floor(pageNumber) {
        case 0:
            pageTitleLabel.text = "Events"
        case 1:
            pageTitleLabel.text = currentEvent?.title
        case 2:
            pageTitleLabel.text = "Talks"
        default:
            break
        }
    }
    private func setPageTitleFrame() {
        pageTitleLabel.font = UIFont(name: "Helvetica Neue", size: 25)
        pageTitleLabel.textColor = UIColor(red: 237/255, green: 164/255, blue: 32/255, alpha: 1)
        pageTitleLabel.textAlignment = .Center
        let vSize: CGSize = getLabelSize(pageTitleLabel)
        let originX = (self.SCREENSIZE.width/2.0 - vSize.width/2.0)
        pageTitleLabel.frame = CGRectMake(originX - 10, 8, vSize.width + 20, vSize.height)
    }
    private func getLabelSize(lbl: UILabel) -> CGSize{
        if let txt = lbl.text {
            return txt.sizeWithAttributes([NSFontAttributeName: lbl.font])
        }
        return CGSizeMake(0, 0)
    }
    private func setPageTitleAlpha(alpha: CGFloat) {
        pageTitleLabel.alpha = alpha
    }
    private func setBarButtonAlpha(pageNumber: CGFloat) {
        if pageNumber < 1 {
            nextArrowButton.tintColor = UIColor(red: 237/255, green: 164/255, blue: 32/255, alpha: 1)
            backArrowButton.tintColor = UIColor.clearColor()
        }
        else if pageNumber > 1 && pageNumber < 1.5 {
            nextArrowButton.tintColor = UIColor(red: 237/255, green: 164/255, blue: 32/255, alpha: 1)
            backArrowButton.tintColor = UIColor(red: 237/255, green: 164/255, blue: 32/255, alpha: 0.5)
        }
        else if pageNumber > 2.0 {
            nextArrowButton.tintColor = UIColor.clearColor()
            backArrowButton.tintColor = UIColor(red: 237/255, green: 164/255, blue: 32/255, alpha: 1)
        }
        else if pageNumber > 1.5 && pageNumber < 2.0 {
            backArrowButton.tintColor = UIColor.orangeColor()
            nextArrowButton.tintColor = UIColor(red: 237/255, green: 164/255, blue: 32/255, alpha: 0.5)
        }
        else {
            nextArrowButton.tintColor = UIColor(red: 237/255, green: 164/255, blue: 32/255, alpha: 1)
            backArrowButton.tintColor = UIColor(red: 237/255, green: 164/255, blue: 32/255, alpha: 1)
        }
    }
    
    
    //MARK: After pull to refresh
    private func reactToRefresh(done: Bool) {
        if done {
            eventListVC.refresh()
            eventInfoVC.refresh()
            talksVC.refresh()
        }
        else {
            noInternetAlert({ (dismiss) -> Void in
                if dismiss {
                    self.eventListVC.refresh()
                    self.eventInfoVC.refresh()
                    self.talksVC.refresh()
                }
            })
        }
    }
    
}
