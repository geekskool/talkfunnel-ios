//
//  DynamicPageViewController.swift
//  Talk Funnel
//
//  Created by Jaison Titus on 10/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

protocol DMDynamicPageViewControllerDelegate {
    func pageViewController(pageController: DMDynamicViewController, didSwitchToViewController viewController: UIViewController)
    func pageViewController(pageController: DMDynamicViewController, didChangeViewControllers viewControllers: Array<UIViewController>)
    func pageIsMoving(pageNumber: CGFloat)
}

class DMDynamicViewController: UIViewController, UIScrollViewDelegate {
    
    var containerScrollView: UIScrollView! = nil
    var pageWidth: CGFloat = 1.0
    var viewControllers:Array<UIViewController>? = nil {
        didSet {
            self.layoutPages()
        }
    }
    var currentPage:Int = 2 {
        didSet {
            if (currentPage >= self.viewControllers?.count)
            {
                self.currentPage = self.viewControllers!.count - 1
            }
            
            containerScrollView.delegate = nil
        containerScrollView.setContentOffset(CGPointMake(CGFloat(self.currentPage) * self.view.bounds.size.width, 0.0), animated: true)
            containerScrollView.delegate = self
            // Set the fully switched page in order to notify the delegates about it if needed.
            self.fullySwitchedPage = self.currentPage;
        }
    }
    var fullySwitchedPage:Int = 0 {
        didSet {
            if (oldValue != self.fullySwitchedPage) {
                // The page is fully switched.
                if (self.fullySwitchedPage < self.viewControllers?.count) {
                    let previousViewController = self.viewControllers?[self.fullySwitchedPage];
                    // Perform the "disappear" sequence of methods manually when the view of
                    // the controller is not visible at all.
                    previousViewController?.willMoveToParentViewController(self)
                    previousViewController?.viewWillDisappear(false)
                    previousViewController?.viewDidDisappear(false)
                    previousViewController?.didMoveToParentViewController(self)
                    previousViewController?.willMoveToParentViewController(self)
                    previousViewController?.viewWillAppear(false)
                    previousViewController?.viewDidAppear(false)
                    previousViewController?.didMoveToParentViewController(self)
                }
            }
        }
    }
    var delegate: DMDynamicPageViewControllerDelegate? = nil
    
    init(viewControllers: Array<UIViewController>) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
        self.notifyDelegateDidChangeControllers()
    }
    
    required override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func willMoveToParentViewController() {
        let page = Int((containerScrollView.contentOffset.x - pageWidth / 2.0) / pageWidth) + 1
        if (self.currentPage != page)
        {
            currentPage = page;
            fullySwitchedPage = page;
        }
    }
    
    override func viewDidLayoutSubviews() {
        for var i = 0; i < self.viewControllers?.count; i += 1 {
            let pageX:CGFloat = CGFloat(i) * self.view.bounds.size.width
            self.viewControllers?[i].view.frame = CGRectMake(pageX, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)
        }
        // It is important to set the pageWidth property before the contentSize and contentOffset,
        // in order to use the new width into scrollView delegate methods.
        pageWidth = self.view.bounds.size.width
        containerScrollView.contentSize = CGSizeMake(CGFloat(self.viewControllers!.count) * self.view.bounds.size.width, 1.0)
        containerScrollView.contentOffset = CGPointMake(CGFloat(self.currentPage) * self.view.bounds.size.width, 0.0)
    }
    
    func layoutPages() {
        for pageView in containerScrollView.subviews {
            pageView.removeFromSuperview()
        }
        
        for var i = 0; i < self.viewControllers?.count; i++ {
            let page = self.viewControllers?[i]
            self.addChildViewController(page!)
            let nextFrame:CGRect = CGRectMake(CGFloat(i) * self.view.bounds.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)
            page?.view.frame = nextFrame
            containerScrollView.addSubview(page!.view)
            page?.didMoveToParentViewController(self)
        }
        containerScrollView.contentSize = CGSizeMake(self.view.bounds.size.width * CGFloat(self.viewControllers!.count), 1.0)
    }
    
    func insertPage(viewController: UIViewController, atIndex index: Int) {
        self.viewControllers?.insert(viewController, atIndex: index)
        self.layoutPages()
        self.currentPage = index
        self.notifyDelegateDidChangeControllers()
    }
    
    func removePage(viewController: UIViewController) {
        for var i = 0; i < self.viewControllers?.count; i += 1 {
            if (self.viewControllers?[i] == viewController) {
                self.viewControllers?.removeAtIndex(i)
                self.layoutPages()
                self.notifyDelegateDidChangeControllers()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerScrollView = UIScrollView(frame: self.view.bounds)
        containerScrollView.pagingEnabled = true
        containerScrollView.bounces = false
        containerScrollView.alwaysBounceVertical = false
        containerScrollView.showsHorizontalScrollIndicator = false
        containerScrollView.delegate = self
        containerScrollView.backgroundColor = UIColor.grayColor()
        self.pageWidth = self.view.frame.size.width
        self.view.addSubview(containerScrollView)
        self.layoutPages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveToPage(pageNumber: CGFloat) {
        containerScrollView.setContentOffset(CGPointMake(pageNumber * self.view.bounds.size.width, 0.0), animated: true)
    }
    
    func notifyDelegateDidSwitchPage() {
        self.delegate?.pageViewController(self, didSwitchToViewController: self.viewControllers![self.currentPage])
    }
    
    func notifyDelegateDidChangeControllers() {
        self.delegate?.pageViewController(self, didChangeViewControllers: self.viewControllers!)
    }
    
    func notifyDelegatePageIsMoving(pageNumber: CGFloat) {
        self.delegate?.pageIsMoving(pageNumber)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //for delegate
        let p = ((containerScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        self.notifyDelegatePageIsMoving(p)
        
        // Update the page when more than 50% of the previous/next page is visible
        let page = floor((containerScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        if (self.currentPage != Int(page)) {
            // Check the page to avoid "index out of bounds" exception.
            if (page >= 0 && Int(page) < self.viewControllers?.count) {
                self.notifyDelegateDidSwitchPage()
            }
        }
        // Check whether the current view controller is fully presented.
        if (Int(containerScrollView.contentOffset.x) % Int(self.pageWidth) == 0)
        {
            //Turn off video capture when the user isnt on the contacts page
            if page != 0.0 {
                contactsVC.scanContactsVC.qrCodeScannerVC.stopRunning()
            }
            else {
                contactsVC.scanContactsVC.qrCodeScannerVC.startRunning()
            }
            self.fullySwitchedPage = self.currentPage;
        }
        
    }
    
}
