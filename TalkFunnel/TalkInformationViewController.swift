//
//  talkInformationViewController.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 03/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import UIKit

class TalkInformationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var talks = [Session]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTalks()
        
        //set the delegate and the datasource of the table view to be the instance of this class (UI View controller)
        tableView.delegate = self
        tableView.dataSource = self
        
        //To make the row height dynamic
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func refresh() {
        getTalks()
        tableView.reloadData()
    }
    
    private func getTalks() {
        for schedulePerDay in schedule {
            for talk in schedulePerDay {
                if talk.isBreak! {
                    continue
                }
                talks.append(talk)
            }
        }
    }
    
    //TableViewDelegate Methods
    
    
    
    
    //TableView Datasource Methods
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talks.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let talkInformationCell = tableView.dequeueReusableCellWithIdentifier("talkInformation", forIndexPath: indexPath) as! TalkInformationCell
        
        let talk = talks[indexPath.row]
        talkInformationCell.setUpCell(talk)
        
        return talkInformationCell
    }
    
    
    //Private Methods
    
    private func getLabelSize(lbl: UILabel) -> CGSize{
        let txt = lbl.text!
        return txt.sizeWithAttributes([NSFontAttributeName: lbl.font])
    }
        

    
}
