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
let talksVC = storyBoard.instantiateViewControllerWithIdentifier("Talks") as! TalkInformationViewController
let loadAppVC = storyBoard.instantiateViewControllerWithIdentifier("LoadApplication") as! LoadApplicationViewController


class LoadApplicationViewController: UIViewController,DMDynamicPageViewControllerDelegate {
    
    @IBOutlet weak var backArrow: UIBarButtonItem!
    @IBOutlet weak var nextArrow: UIBarButtonItem!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    var pageTitleLabel = UILabel()
    var currentPageNumber: CGFloat = 2.0
    
    private var SCREENSIZE: CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpApp()
    }
    
    private func setUpApp() {
        setUpLoadingScreen()
        getLocalData()
        fetchDataForEventList { (doneFetching,error) -> Void in
            if doneFetching {
                theEvent = currentEvent
                theEventInformation = currentEventInformation
                saveFetchedEventData()
                self.setUpPageView()
            }
            else {
                if error != nil {
                    self.noInternetConnection()
                }
                else {
                    self.setUpApp()
                }
            }
        }
    }
    
    private func setUpLoadingScreen() {
        loadingIcon.startAnimating()
        hideNavigationBar()
    }
    
    private func setUpPageView() {
        loadingIcon.stopAnimating()
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
        talksVC.resetTalksScroll()
    }
    
    private func setUpNavigationBar() {
        navigationController?.navigationBar.addSubview(pageTitleLabel)
        navigationController?.navigationBarHidden = false
        navigationController?.navigationBar.translucent = false
    }
    
    private func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func loadAppFromCache() {
        fetchSavedEventData { (doneFetching) -> Void in
            if doneFetching {
                theEvent = currentEvent
                theEventInformation = currentEventInformation
                self.setUpPageView()
            }
            else {
                //error
            }
        }
    }

    func noInternetConnection() {
        loadingIcon.stopAnimating()
        let noInternetConnectionAlert = UIAlertController(title: "Connection Error", message: "Unable to connect to the internet.Data may not be up to date.", preferredStyle: UIAlertControllerStyle.Alert)
        let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.setUpApp()
        })
        let continueAction = UIAlertAction(title: "Continue Anyway", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.loadAppFromCache()
        })
        noInternetConnectionAlert.addAction(tryAgainAction)
        noInternetConnectionAlert.addAction(continueAction)
        self.presentViewController(noInternetConnectionAlert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func onBackPressed(sender: UIBarButtonItem) {
        switch currentPageNumber {
        case 0:
            logOut()
        case 1:
            changeBarButtonImage(backArrow, imageName: "Logout")
            currentPageNumber--
        case 4:
            nextArrow.tintColor = UIColor.orangeColor()
            currentPageNumber--
        default:
            currentPageNumber--
        }
        pageController?.moveToPage(currentPageNumber)
    }
    
    @IBAction func onNextPressed(sender: UIBarButtonItem) {
        nextArrow.tintColor = UIColor.orangeColor()
        switch currentPageNumber {
        case 0:
            changeBarButtonImage(backArrow, imageName: "Back")
            currentPageNumber++
        case 3:
            nextArrow.tintColor = UIColor.clearColor()
            currentPageNumber++
        case 4:
            nextArrow.tintColor = UIColor.clearColor()
        default:
            currentPageNumber++
        }
        pageController?.moveToPage(currentPageNumber)
    }
    
    
    private func logOut() {
        userAccessToken = nil
        userTokenType = nil
        addToLocalData()
        isUserLoggedIn = false
        backArrow.tintColor = UIColor.clearColor()
        contactsVC.refresh()
    }
    
    private func changeBarButtonImage(barButton: UIBarButtonItem,imageName: String) {
        var image = UIImage(named: imageName)
        image = image?.imageWithRenderingMode(.AlwaysTemplate)
        barButton.image = image
    }
    
    //DMDynamic Page View controller Delegate Method
    func pageIsMoving(pageNumber: CGFloat) {
        let value = 2*(pageNumber - floor(pageNumber))
        let alpha = getAlpha(value)
        
        currentPageNumber = floor(pageNumber)
        setPageTitle(pageNumber)
        setPageTitleFrame()
        setPageTitleAlpha(alpha)
        
        setBarButtonImage(pageNumber)
        if pageNumber < 1.5 || pageNumber > 3.5 {
            setBarButtonAlpha(alpha)
        }
        
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
    
    private func setBarButtonImage(pageNumber: CGFloat) {
        switch floor(pageNumber) {
        case 0:
            changeBarButtonImage(backArrow, imageName: "Logout")
        case 1:
            changeBarButtonImage(backArrow, imageName: "Back")
        default:
            break
        }
    }
    
    private func setBarButtonAlpha(alpha: CGFloat) {
        switch currentPageNumber {
        case 0:
            if isUserLoggedIn {
               backArrow.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: alpha)
            }
            else {
                backArrow.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: 0.0)
            }

        case 1:
            backArrow.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: alpha)
        case 2:
            backArrow.tintColor = UIColor.orangeColor()
        case 3:
            nextArrow.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: alpha)
        case 4:
            nextArrow.tintColor = UIColor.clearColor()
        default :
            break
        }
        

    }
    
    private func setPageTitle(pageNumber: CGFloat) {
        switch floor(pageNumber) {
        case 0:
            if isUserLoggedIn {
                pageTitleLabel.text = "Contacts"
            }
            else {
                pageTitleLabel.text = "Log In"
            }
        case 1:
            pageTitleLabel.text = "Events"
        case 2:
            pageTitleLabel.text = currentEvent?.title
        case 3:
            pageTitleLabel.text = "Talks"
        case 4:
            pageTitleLabel.text = "Chat"
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
    
    
    func pageViewController(pageController: DMDynamicViewController, didSwitchToViewController viewController: UIViewController) {
        
    }
    
    func pageViewController(pageController: DMDynamicViewController, didChangeViewControllers viewControllers: Array<UIViewController>) {
        
    }
    
    
    //MARK: Method called after user logs in and after AUTH
    func makeLogOutButtonVisible() {
        backArrow.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: 1.0)
    }
}
