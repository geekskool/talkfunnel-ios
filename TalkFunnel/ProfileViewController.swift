//
//  ProfileViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 10/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate {
    func logOutButtonClicked()
}
class ProfileViewController: UIViewController {

    var delegate: ProfileViewControllerDelegate?
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.logOutButton.layer.cornerRadius = 10
    }
    
    @IBAction func logOutButtonClicked(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.logOutButtonClicked()
        }
    }

}
