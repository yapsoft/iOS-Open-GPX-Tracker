//
//  UIHeaderLayer.swift
//  OpenGpxTracker
//
//  Created by Vincent on 23/4/19.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import UIKit

class UIHeaderLayer: UIView {
    
    var appTitleLabel: UILabel
    var coordsLabel: UILabel
    
    override init(frame: CGRect) {
        self.appTitleLabel = UILabel(frame: frame)
        self.coordsLabel = UILabel(frame: frame)
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.appTitleLabel = UILabel(coder: aDecoder)!
        self.coordsLabel = UILabel(coder: aDecoder)!
        
        super.init(coder: aDecoder)
    }
    
    func setupLayer(with map: GPXMapView, view: UIView, isIPhoneX: Bool) {
        //
        // ---------------------- Build Interface Area -----------------------------
        //
        // HEADER
        let font36 = UIFont(name: "DinCondensed-Bold", size: 36.0)
        let font18 = UIFont(name: "DinAlternate-Bold", size: 18.0)
        let font12 = UIFont(name: "DinAlternate-Bold", size: 12.0)
        
        //add the app title Label (Branding, branding, branding! )
        let appTitleW: CGFloat = view.frame.width//200.0
        let appTitleH: CGFloat = 14.0
        let appTitleX: CGFloat = 0 //self.view.frame.width/2 - appTitleW/2
        let appTitleY: CGFloat = isIPhoneX ? 40.0 : 20.0
        appTitleLabel.frame = CGRect(x:appTitleX, y: appTitleY, width: appTitleW, height: appTitleH)
        appTitleLabel.text = "  Open GPX Tracker"
        appTitleLabel.textAlignment = .left
        appTitleLabel.font = UIFont.boldSystemFont(ofSize: 10)
        //appTitleLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        appTitleLabel.textColor = UIColor.yellow
        appTitleLabel.backgroundColor = UIColor(red: 58.0/255.0, green: 57.0/255.0, blue: 54.0/255.0, alpha: 0.80)
        appTitleLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        self.addSubview(appTitleLabel)
        
        // CoordLabel
        coordsLabel.frame = CGRect(x: map.frame.width - 305, y: appTitleY, width: 300, height: 12)
        coordsLabel.textAlignment = .right
        coordsLabel.font = font12
        coordsLabel.textColor = UIColor.white
        coordsLabel.text = kNotGettingLocationText
        coordsLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        self.addSubview(coordsLabel)
    }
}
