////
////  LoadApplicationViewController.swift
////  TalkFunnel
////
////  Created by Jaison Titus on 12/08/15.
////  Copyright © 2015 Hasgeek. All rights reserved.
////
//
//import UIKit
//
////MARK: Global Declarations
//
//let storyBoard = UIStoryboard(name: "Main",bundle: nil)
//let contactsVC = storyBoard.instantiateViewControllerWithIdentifier("Contacts") as! ContactsViewController
//let chatVC = storyBoard.instantiateViewControllerWithIdentifier("Chat") as UIViewController
//let eventsVC = storyBoard.instantiateViewControllerWithIdentifier("MainEvents") as UIViewController
//let eventInfoVC = storyBoard.instantiateViewControllerWithIdentifier("EventInformation") as! EventInformationViewController
//let eventListVC = storyBoard.instantiateViewControllerWithIdentifier("EventList") as UIViewController
//let talksVC = storyBoard.instantiateViewControllerWithIdentifier("Talks") as! TalkInformationViewController
//let loadAppVC = storyBoard.instantiateViewControllerWithIdentifier("LoadApplication") as! LoadApplicationViewController
//
//
//class LoadApplicationViewController: UIViewController,DMDynamicPageViewControllerDelegate {
//
//
//    
//    //MARK: APPSTARTSHERE
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setUpApp()
//    }
//    
//    private func setUpApp() {
//        setUpLoadingScreen()
//        getLocalData()
//        fetchAllData { (doneFetchingData, errorFetchingData) -> Void in
//            if doneFetchingData {
//                self.setUpPageView()
//            }
//            else {
//                if errorFetchingData != nil {
//                    self.noInternetConnection()
//                }
//                else {
//                    self.setUpApp()
//                }
//            }
//        }
//    }
//    
//    private func setUpLoadingScreen() {
//        loadingIcon.startAnimating()
//        hideNavigationBar()
//    }
//    
//    private func setUpPageView() {
//        loadingIcon.stopAnimating()
//        
//    }
//    
//    
//    
//    private func hideNavigationBar() {
//        navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//    
//    private func showNavigationBar() {
//        navigationController?.setNavigationBarHidden(false, animated: true)
//    }
//    
//    //MARK: Offline Support
//    func noInternetConnection() {
//        loadingIcon.stopAnimating()
//        let noInternetConnectionAlert = UIAlertController(title: "Connection Error", message: "Unable to connect to the internet.Data may not be up to date.", preferredStyle: UIAlertControllerStyle.Alert)
//        let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//            self.setUpApp()
//        })
//        let continueAction = UIAlertAction(title: "Continue Anyway", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//            self.loadAppFromCache()
//        })
//        noInternetConnectionAlert.addAction(tryAgainAction)
//        noInternetConnectionAlert.addAction(continueAction)
//        self.presentViewController(noInternetConnectionAlert, animated: true, completion: nil)
//    }
//    
//    private func loadAppFromCache() {
//        fetchAllSavedData({ (doneFetching, error) -> Void in
//            if doneFetching {
//                self.getSelectedEventFromEventList()
//                self.setUpPageView()
//            }
//            else {
//                //error
//            }
//        })
//    }
//
//    
//    //MARK: BarButton Methods
//    private func setBarButtonImage(pageNumber: CGFloat) {
//        switch floor(pageNumber) {
//        case 0:
//            changeBarButtonImage(backArrow, imageName: "Logout")
//        case 1:
//            changeBarButtonImage(backArrow, imageName: "Back")
//        default:
//            break
//        }
//    }
//    private func setBarButtonAlpha(alpha: CGFloat) {
//        switch currentPageNumber {
//        case 0:
//            if isUserLoggedIn {
//                backArrow.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: alpha)
//            }
//            else {
//                backArrow.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: 0.0)
//            }
//            
//        case 1:
//            backArrow.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: alpha)
//        case 2:
//            backArrow.tintColor = UIColor.orangeColor()
//        case 3:
//            nextArrow.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: alpha)
//        case 4:
//            nextArrow.tintColor = UIColor.clearColor()
//        default :
//            break
//        }
//    }
//    
//    private func changeBarButtonImage(barButton: UIBarButtonItem,imageName: String) {
//        var image = UIImage(named: imageName)
//        image = image?.imageWithRenderingMode(.AlwaysTemplate)
//        barButton.image = image
//    }
//    
//    @IBAction func onBackPressed(sender: UIBarButtonItem) {
//        switch currentPageNumber {
//        case 0:
//            logOut()
//        case 1:
//            changeBarButtonImage(backArrow, imageName: "Logout")
//            currentPageNumber--
//        case 4:
//            nextArrow.tintColor = UIColor.orangeColor()
//            currentPageNumber--
//        default:
//            currentPageNumber--
//        }
//        pageController?.moveToPage(currentPageNumber)
//    }
//    
//    @IBAction func onNextPressed(sender: UIBarButtonItem) {
//        nextArrow.tintColor = UIColor.orangeColor()
//        switch currentPageNumber {
//        case 0:
//            changeBarButtonImage(backArrow, imageName: "Back")
//            currentPageNumber++
//        case 3:
//            nextArrow.tintColor = UIColor.clearColor()
//            currentPageNumber++
//        case 4:
//            nextArrow.tintColor = UIColor.clearColor()
//        default:
//            currentPageNumber++
//        }
//        pageController?.moveToPage(currentPageNumber)
//    }
//    
//    //MARK: LogOut
//    private func logOut() {
//        userAccessToken = nil
//        userTokenType = nil
//        addToLocalData()
//        isUserLoggedIn = false
//        backArrow.tintColor = UIColor.clearColor()
//        contactsVC.refresh()
//    }
//    
//
//    //MARK: Method called after user logs in and after AUTH
//    func makeLogOutButtonVisible() {
//        backArrow.tintColor = UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: 1.0)
//    }
//}
