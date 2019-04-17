//
//  UIButtonsLayer.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 17/4/19.
//

import UIKit

class UIInteractableLayer: UIView {
    
    // Buttons
    var followUserButton = UIButton()
    var newPinButton = UIButton()
    var folderButton = UIButton()
    var aboutButton = UIButton()
    var preferencesButton = UIButton()
    var shareButton = UIButton()
    var resetButton = UIButton()
    var trackerButton = UIButton()
    var saveButton = UIButton()
    
    
    required init?(coder aDecoder: NSCoder) {
        //self.followUserButton = UIButton(coder: aDecoder)!
        
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, iPhoneXdiff: CGFloat) {
        super.init(frame: frame)
        
        //about button
        aboutButton.frame = CGRect(x: 5 + 8, y: 14 + 5 + 48 + 5 + iPhoneXdiff, width: 32, height: 32)
        aboutButton.setImage(UIImage(named: "info"), for: UIControl.State())
        aboutButton.setImage(UIImage(named: "info_high"), for: .highlighted)
        aboutButton.addTarget(self, action: #selector(ViewController.openAboutViewController), for: .touchUpInside)
        aboutButton.autoresizingMask = [.flexibleRightMargin]
        //aboutButton.backgroundColor = kWhiteBackgroundColor
        //aboutButton.layer.cornerRadius = 24
        self.addSubview(aboutButton)
        
        // Preferences button
        preferencesButton.frame = CGRect(x: 5 + 10 + 48, y: 14 + 5 + 8  + iPhoneXdiff, width: 32, height: 32)
        preferencesButton.setImage(UIImage(named: "prefs"), for: UIControl.State())
        preferencesButton.setImage(UIImage(named: "prefs_high"), for: .highlighted)
        preferencesButton.addTarget(self, action: #selector(ViewController.openPreferencesTableViewController), for: .touchUpInside)
        preferencesButton.autoresizingMask = [.flexibleRightMargin]
        //aboutButton.backgroundColor = kWhiteBackgroundColor
        //aboutButton.layer.cornerRadius = 24
        self.addSubview(preferencesButton)
        
        // Share button
        shareButton.frame = CGRect(x: 5 + 10 + 48 * 2, y: 14 + 5 + 8  + iPhoneXdiff, width: 32, height: 32)
        shareButton.setImage(UIImage(named: "share"), for: UIControl.State())
        shareButton.setImage(UIImage(named: "share_high"), for: .highlighted)
        shareButton.addTarget(self, action: #selector(ViewController.openShare), for: .touchUpInside)
        shareButton.autoresizingMask = [.flexibleRightMargin]
        //aboutButton.backgroundColor = kWhiteBackgroundColor
        //aboutButton.layer.cornerRadius = 24
        self.addSubview(shareButton)
        
        // Folder button
        let folderW: CGFloat = kButtonSmallSize
        let folderH: CGFloat = kButtonSmallSize
        let folderX: CGFloat = folderW/2 + 5
        let folderY: CGFloat = folderH/2 + 5 + 14  + iPhoneXdiff
        folderButton.frame = CGRect(x: 0, y: 0, width: folderW, height: folderH)
        folderButton.center = CGPoint(x: folderX, y: folderY)
        folderButton.setImage(UIImage(named: "folder"), for: UIControl.State())
        folderButton.setImage(UIImage(named: "folderHigh"), for: .highlighted)
        folderButton.addTarget(self, action: #selector(ViewController.openFolderViewController), for: .touchUpInside)
        folderButton.backgroundColor = kWhiteBackgroundColor
        folderButton.layer.cornerRadius = 24
        folderButton.autoresizingMask = [.flexibleRightMargin]
        self.addSubview(folderButton)
        
        /* Signal Image View to be refracted later.
         // Add signal accuracy images and labels
         signalImageView.image = signalImage0
         signalImageView.frame = CGRect(x: self.view.frame.width/2 - 25.0, y:  14 + 5 + iPhoneXdiff, width: 50, height: 30)
         signalImageView.autoresizingMask  = [.flexibleLeftMargin, .flexibleRightMargin]
         map.addSubview(signalImageView)
         signalAccuracyLabel.frame = CGRect(x: self.view.frame.width/2 - 25.0, y:  14 + 5 + 30 + iPhoneXdiff , width: 50, height: 12)
         signalAccuracyLabel.font = font12
         signalAccuracyLabel.text = kUnknownAccuracyText
         signalAccuracyLabel.textAlignment = .center
         signalAccuracyLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
         map.addSubview(signalAccuracyLabel)
         
         */
        
        //
        // Button Bar
        //
        // [ Small ] [ Small ] [ Large     ] [Small] [ Small]
        //                     [ (tracker) ]
        //
        //                     [ track     ]
        // [ follow] [ +Pin  ] [ Pause     ] [ Save ] [ Reset]
        //                     [ Resume    ]
        //
        //                       trackerX
        //                         |
        //                         |
        // [-----------------------|--------------------------]
        //                  map.frame/2 (center)
        
        let yCenterForButtons: CGFloat = frame.height - kButtonLargeSize/2 - 5 //center Y of start
        
        
        // Start/Pause button
        let trackerW: CGFloat = kButtonLargeSize
        let trackerH: CGFloat = kButtonLargeSize
        let trackerX: CGFloat = frame.width/2 - 0.0 // Center of start
        let trackerY: CGFloat = yCenterForButtons
        trackerButton.frame = CGRect(x: 0, y:0, width: trackerW, height: trackerH)
        trackerButton.center = CGPoint(x: trackerX, y: trackerY)
        trackerButton.layer.cornerRadius = trackerW/2
        trackerButton.setTitle("Start Tracking", for: UIControl.State())
        trackerButton.backgroundColor = kGreenButtonBackgroundColor
        trackerButton.addTarget(self, action: #selector(ViewController.trackerButtonTapped), for: .touchUpInside)
        trackerButton.isHidden = false
        trackerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        trackerButton.titleLabel?.numberOfLines = 2
        trackerButton.titleLabel?.textAlignment = .center
        trackerButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        self.addSubview(trackerButton)
        
        // Pin Button (on the left of start)
        let newPinW: CGFloat = kButtonSmallSize
        let newPinH: CGFloat = kButtonSmallSize
        let newPinX: CGFloat = trackerX - trackerW/2 - kButtonSeparation - newPinW/2
        let newPinY: CGFloat = yCenterForButtons
        newPinButton.frame = CGRect(x: 0, y: 0, width: newPinW, height: newPinH)
        newPinButton.center = CGPoint(x: newPinX, y: newPinY)
        newPinButton.layer.cornerRadius = newPinW/2
        newPinButton.backgroundColor = kWhiteBackgroundColor
        newPinButton.setImage(UIImage(named: "addPin"), for: UIControl.State())
        newPinButton.setImage(UIImage(named: "addPinHigh"), for: .highlighted)
        newPinButton.addTarget(self, action: #selector(ViewController.addPinAtMyLocation), for: .touchUpInside)
        newPinButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        //let newPinLongPress = UILongPressGestureRecognizer(target: self, action: Selector("newPinLongPress:"))
        //newPinButton.addGestureRecognizer(newPinLongPress)
        self.addSubview(newPinButton)
        
        // Follow user button
        let followW: CGFloat = kButtonSmallSize
        let followH: CGFloat = kButtonSmallSize
        let followX: CGFloat = newPinX - newPinW/2 - kButtonSeparation - followW/2
        let followY: CGFloat = yCenterForButtons
        followUserButton.frame = CGRect(x: 0, y: 0, width: followW, height: followH)
        followUserButton.center = CGPoint(x: followX, y: followY)
        followUserButton.layer.cornerRadius = followW/2
        followUserButton.backgroundColor = kWhiteBackgroundColor
        //follow_user_high represents the user is being followed. Default status when app starts
        followUserButton.setImage(UIImage(named: "follow_user_high"), for: UIControl.State())
        followUserButton.setImage(UIImage(named: "follow_user_high"), for: .highlighted)
        followUserButton.addTarget(self, action: #selector(ViewController.followButtonTroggler), for: .touchUpInside)
        followUserButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        self.addSubview(followUserButton)
        
        // Save button
        let saveW: CGFloat = kButtonSmallSize
        let saveH: CGFloat = kButtonSmallSize
        let saveX: CGFloat = trackerX + trackerW/2 + kButtonSeparation + saveW/2
        let saveY: CGFloat = yCenterForButtons
        saveButton.frame = CGRect(x: 0, y: 0, width: saveW, height: saveH)
        saveButton.center = CGPoint(x: saveX, y: saveY)
        saveButton.layer.cornerRadius = saveW/2
        saveButton.setTitle("Save", for: UIControl.State())
        saveButton.backgroundColor = kDisabledBlueButtonBackgroundColor
        saveButton.addTarget(self, action: #selector(ViewController.saveButtonTapped), for: .touchUpInside)
        saveButton.isHidden = false
        saveButton.titleLabel?.textAlignment = .center
        saveButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        self.addSubview(saveButton)
        
        // Reset button
        let resetW: CGFloat = kButtonSmallSize
        let resetH: CGFloat = kButtonSmallSize
        let resetX: CGFloat = saveX + saveW/2 + kButtonSeparation + resetW/2
        let resetY: CGFloat = yCenterForButtons
        resetButton.frame = CGRect(x: 0, y: 0, width: resetW, height: resetH)
        resetButton.center = CGPoint(x: resetX, y: resetY)
        resetButton.layer.cornerRadius = resetW/2
        resetButton.setTitle("Reset", for: UIControl.State())
        resetButton.backgroundColor = kDisabledRedButtonBackgroundColor
        resetButton.addTarget(self, action: #selector(ViewController.resetButtonTapped), for: .touchUpInside)
        resetButton.isHidden = false
        resetButton.titleLabel?.textAlignment = .center
        resetButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        self.addSubview(resetButton)
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
