//
//  talkView.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 16/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import UIKit

@IBDesignable class talkView: UIView {

    @IBOutlet weak var talkTitle: UILabel!
    @IBOutlet weak var speakerName: UILabel!
    @IBOutlet weak var timeAndDate: UILabel!
    @IBOutlet weak var roomAndVenue: UILabel!
    @IBOutlet weak var sectionType: UILabel!
    @IBOutlet weak var technicalLevel: UILabel!
    @IBOutlet weak var speakerBio: UILabel!
    @IBOutlet weak var talkDescription: UILabel!
    var talk: Session?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadViewFromNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "talkView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame.size.width = frame.width
        view.sizeToFit()
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(view)
    }

}



