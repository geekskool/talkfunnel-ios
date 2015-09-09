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
        setUpDelegates()
        setUpPageController()
        setUpNavigationBar()
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
        view.addSubview(pageController!.view)
        talksVC.resetTalksScroll()
    }
    
    private func setUpNavigationBar() {
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 66)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.translucent = true
        navigationBar.delegate = self
        
        // Create left and right button for navigation item
        var image = UIImage(named: "Back")
        image = image?.imageWithRenderingMode(.AlwaysTemplate)
        let leftButton =  UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonClicked:")
        var image2 = UIImage(named: "Back")
        image2 = image2?.imageWithRenderingMode(.AlwaysTemplate)
        let rightButton = UIBarButtonItem(image: image2, style: UIBarButtonItemStyle.Plain, target: self, action: "nextButtonClicked:")
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        navigationBar.addSubview(pageTitleLabel)
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
    }
    
    //MARK: EventListViewControllerDelegate Method
    func didSelectEvent(event: EventList) {
        pageController?.moveToPage(1)
        if let currentEventDetail = currentEvent {
            if currentEventDetail.title! == event.title && currentEventDetail.jsonUrl! == event.jsonUrl {
                eventInfoVC.refresh()
                talksVC.refresh()
            }
            else {
                let tempEvent = currentEvent
                currentEvent = event
                eventInfoVC.addLoadingDataView()
                talksVC.addLoadingDataView()
                fetchDataForEvent { (doneFetching,error) -> Void in
                    if doneFetching {
                        currentEventTitle = currentEvent?.title
                        addToLocalData()
                        self.eventInfoVC.refresh()
                        self.talksVC.refresh()
                        fetchParticipantRelatedData("participants/json", callback: { (done, error) -> Void in
                            if done {
                                
                            }
                            else {
                                
                            }
                        })
                    }
                    else {
                        currentEvent = tempEvent
                    }
                }
            }
        }
    }
    
    //Mark: EventInformationViewControllerDelegate Method
    func didSelectTalk(talk: Session) {
        pageController?.moveToPage(2)
        talksVC.scrollToSelectedTalk(talk)
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
        pageTitleLabel.font = UIFont.boldSystemFontOfSize(25)
        pageTitleLabel.textColor = UIColor.orangeColor()
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
        if pageNumber < 1.5 {
            backArrowButton.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: 2 - pageNumber)
            nextArrowButton.tintColor = UIColor.orangeColor()
        }
        else if pageNumber > 1.5 {
            nextArrowButton.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: pageNumber - 1)
            backArrowButton.tintColor = UIColor.orangeColor()
        }
        else {
            nextArrowButton.tintColor = UIColor.orangeColor()
            backArrowButton.tintColor = UIColor.orangeColor()
        }
        
        if pageNumber == 1 {
            nextArrowButton.tintColor = UIColor.orangeColor()
            backArrowButton.tintColor = UIColor.clearColor()
        }
        if pageNumber == 2 {
            nextArrowButton.tintColor = UIColor.clearColor()
            backArrowButton.tintColor = UIColor.orangeColor()
        }
    }
    
}
