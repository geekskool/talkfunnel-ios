//
//  MainViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 09/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpApp()
    }
    
    private func setUpApp() {
        activityIndicator.startAnimating()
        fetchData()
    }
    
    private func fetchData() {
        getLocalData()
        if hasAppRunBefore != nil {
            fetchDataFromMemory()
        }
        else {
            fetchDataFromServer()
        }
    }
    
    private func fetchDataFromMemory() {
        fetchAllSavedData({ (doneFetching, error) -> Void in
            if doneFetching {
                self.activityIndicator.stopAnimating()
                self.performSegueWithIdentifier("switchesToTabBarVC", sender: nil)
            }
            else {
                self.fetchDataFromServer()
            }
        })
    }
    
    private func fetchDataFromServer() {
        fetchAllData { (doneFetching, error) -> Void in
            if doneFetching {
                self.getSelectedEventFromEventList()
                self.activityIndicator.stopAnimating()
                self.performSegueWithIdentifier("switchesToTabBarVC", sender: nil)
            }
            else {
                self.showAlert("Connection Error", message: "Please ensure you are connected to the internet")
            }
        }
    }
    
    private func getSelectedEventFromEventList() {
        for event in eventList {
            if let eventTitle = currentEventTitle {
                if event.title == eventTitle {
                    currentEvent = event
                }
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tabVC = segue.destinationViewController as? MainTabBarController {
            tabVC.setUpVC()
        }
    }
    
    //MARK: Alert
    private func showAlert(title: String,message: String) {
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.setUpApp()
        })
        alert.addAction(tryAgainAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
