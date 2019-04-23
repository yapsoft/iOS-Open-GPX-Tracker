//
//  UIButtonsLayer.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 17/4/19.
//

import UIKit

class UIInteractableLayer: UIView {
    
    /*
    //UI
    //labels
    var appTitleLabel: UILabel
    //var appTitleBackgroundView: UIView
    var signalImageView: UIImageView
    var signalAccuracyLabel: UILabel
    var coordsLabel: UILabel
    var timeLabel: UILabel
    var speedLabel: UILabel
    var totalTrackedDistanceLabel: UIDistanceLabel
    var currentSegmentDistanceLabel: UIDistanceLabel
 */
 
    // Buttons
    var followUserButton: UIButton
    var newPinButton: UIButton
    var folderButton: UIButton
    var aboutButton: UIButton
    var preferencesButton: UIButton
    var shareButton: UIButton
    var resetButton: UIButton
    var trackerButton: UIButton
    var saveButton: UIButton
    
    
    required init?(coder aDecoder: NSCoder) {
        //self.followUserButton = UIButton(coder: aDecoder)!
        
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, iPhoneXdiff: CGFloat) {
        super.init(frame: frame)
        
    }
    
    func loadLayer(_ iPhoneXdiff: CGFloat) {
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
