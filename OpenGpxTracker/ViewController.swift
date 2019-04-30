//
//  ViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 13/09/14.
//

import UIKit
import CoreLocation
import MapKit
import CoreGPX
import WatchConnectivity

//Button colors
let kPurpleButtonBackgroundColor: UIColor =  UIColor(red: 146.0/255.0, green: 166.0/255.0, blue: 218.0/255.0, alpha: 0.90)
let kGreenButtonBackgroundColor: UIColor = UIColor(red: 142.0/255.0, green: 224.0/255.0, blue: 102.0/255.0, alpha: 0.90)
let kRedButtonBackgroundColor: UIColor =  UIColor(red: 244.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.90)
let kBlueButtonBackgroundColor: UIColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 0.90)
let kDisabledBlueButtonBackgroundColor: UIColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 0.10)
let kDisabledRedButtonBackgroundColor: UIColor =  UIColor(red: 244.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.10)
let kWhiteBackgroundColor: UIColor = UIColor(red: 254.0/255.0, green: 254.0/255.0, blue: 254.0/255.0, alpha: 0.90)

//Accesory View buttons tags
let kDeleteWaypointAccesoryButtonTag = 666
let kEditWaypointAccesoryButtonTag = 333

let kNotGettingLocationText = "Not getting location"
let kUnknownAccuracyText = "±···m"
let kUnknownSpeedText = "·.··"

/// Size for small buttons
let  kButtonSmallSize: CGFloat = 48.0
/// Size for large buttons
let kButtonLargeSize: CGFloat = 96.0
/// Separation between buttons
let kButtonSeparation: CGFloat = 6.0

/// Upper limits threshold (in meters) on signal accuracy.
let kSignalAccuracy6 = 6.0
let kSignalAccuracy5 = 11.0
let kSignalAccuracy4 = 31.0
let kSignalAccuracy3 = 51.0
let kSignalAccuracy2 = 101.0
let kSignalAccuracy1 = 201.0

///
/// Main View Controller of the Application. It is loaded when the application is launched
///
/// Displays a map and a set the buttons to control the tracking
///
///
class ViewController: UIViewController, UIGestureRecognizerDelegate  {
    
    /// Shall the map be centered on current user position?
    /// If yes, whenever the user moves, the center of the map too.
    var followUser: Bool = true {
        didSet {
            if followUser {
                print("followUser=true")
                interactableLayer.followUserButton.setImage(UIImage(named: "follow_user_high"), for: UIControl.State())
                map.setCenter((map.userLocation.coordinate), animated: true)
                
            } else {
                print("followUser=false")
                interactableLayer.followUserButton.setImage(UIImage(named: "follow_user"), for: UIControl.State())
            }
            
        }
    }
    
    var followUserBeforePinchGesture = true
    
    
    //MapView
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2 //meters
        manager.headingFilter = 1 //degrees (1 is default)
        manager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        }
        return manager
    }()
    
    /// Map View
    var map: GPXMapView
    
    /// Map View delegate 
    let mapViewDelegate = MapViewDelegate()
    
    //Status Vars
    var stopWatch = StopWatch()
    var lastGpxFilename: String = ""
    var wasSentToBackground: Bool = false //Was the app sent to background
    var isDisplayingLocationServicesDenied: Bool = false
    
    /// Has the map any waypoint?
    var hasWaypoints: Bool = false {
        /// Whenever it is updated, if it has waypoints it sets the save and reset button
        didSet {
            if hasWaypoints {
                interactableLayer.saveButton.backgroundColor = kBlueButtonBackgroundColor
                interactableLayer.resetButton.backgroundColor = kRedButtonBackgroundColor
            }
        }
    }
    
   
    /// Defines the different statuses regarding tracking current user location.
    enum GpxTrackingStatus {
        
        /// Tracking has not started or map was reset
        case notStarted
        
        /// Tracking is ongoing
        case tracking
        
        /// Tracking is paused (the map has some contents)
        case paused
    }
    
    /// Tells what is the current status of the Map Instance.
    var gpxTrackingStatus: GpxTrackingStatus = GpxTrackingStatus.notStarted {
        didSet {
            print("gpxTrackingStatus changed to \(gpxTrackingStatus)")
            switch gpxTrackingStatus {
            case .notStarted:
                print("switched to non started")
                // set Tracker button to allow Start 
                interactableLayer.trackerButton.setTitle("Start Tracking", for: UIControl.State())
                interactableLayer.trackerButton.backgroundColor = kGreenButtonBackgroundColor
                //save & reset button to transparent.
                interactableLayer.saveButton.backgroundColor = kDisabledBlueButtonBackgroundColor
                interactableLayer.resetButton.backgroundColor = kDisabledRedButtonBackgroundColor
                //reset clock
                stopWatch.reset()
                interactableLayer.timeLabel.text = stopWatch.elapsedTimeString
                
                map.clearMap() //clear map
                lastGpxFilename = "" //clear last filename, so when saving it appears an empty field
                
                interactableLayer.totalTrackedDistanceLabel.distance = (map.totalTrackedDistance)
                interactableLayer.currentSegmentDistanceLabel.distance = (map.currentSegmentDistance)
                
                /*
                // XXX Left here for reference
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    self.trackerButton.hidden = true
                    self.pauseButton.hidden = false
                    }, completion: {(f: Bool) -> Void in
                        println("finished animation start tracking")
                })
                */
                
            case .tracking:
                print("switched to tracking mode")
                // set tracerkButton to allow Pause
                interactableLayer.trackerButton.setTitle("Pause", for: UIControl.State())
                interactableLayer.trackerButton.backgroundColor = kPurpleButtonBackgroundColor
                //activate save & reset buttons
                interactableLayer.saveButton.backgroundColor = kBlueButtonBackgroundColor
                interactableLayer.resetButton.backgroundColor = kRedButtonBackgroundColor
                // start clock
                self.stopWatch.start()
                
            case .paused:
                print("switched to paused mode")
                // set trackerButton to allow Resume
                interactableLayer.trackerButton.setTitle("Resume", for: UIControl.State())
                interactableLayer.trackerButton.backgroundColor = kGreenButtonBackgroundColor
                // activate save & reset (just in case switched from .NotStarted)
                interactableLayer.saveButton.backgroundColor = kBlueButtonBackgroundColor
                interactableLayer.resetButton.backgroundColor = kRedButtonBackgroundColor
                //pause clock
                self.stopWatch.stop()
                // start new track segment
                self.map.startNewTrackSegment()
            }
        }
    }

    /// Editing Waypoint Temporal Reference
    var lastLocation: CLLocation? //Last point of current segment.
    
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
    */
    // Signal accuracy images
    let signalImage0 = UIImage(named: "signal0")
    let signalImage1 = UIImage(named: "signal1")
    let signalImage2 = UIImage(named: "signal2")
    let signalImage3 = UIImage(named: "signal3")
    let signalImage4 = UIImage(named: "signal4")
    let signalImage5 = UIImage(named: "signal5")
    let signalImage6 = UIImage(named: "signal6")
 
    
    var interactableLayer: UIInteractableLayer
    var headerLayer: UIHeaderLayer
 
    // Initializer. Just initializes the class vars/const
    required init(coder aDecoder: NSCoder) {
        self.map = GPXMapView(coder: aDecoder)!
        
        /*
        self.appTitleLabel = UILabel(coder: aDecoder)!
        self.signalImageView = UIImageView(coder: aDecoder)!
        self.signalAccuracyLabel = UILabel(coder: aDecoder)!
        self.coordsLabel = UILabel(coder: aDecoder)!
        
        self.timeLabel = UILabel(coder: aDecoder)!
        self.speedLabel = UILabel(coder: aDecoder)!
        self.totalTrackedDistanceLabel = UIDistanceLabel(coder: aDecoder)!
        self.currentSegmentDistanceLabel = UIDistanceLabel(coder: aDecoder)!
        
        self.followUserButton = UIButton(coder: aDecoder)!
        self.newPinButton = UIButton(coder: aDecoder)!
        self.folderButton = UIButton(coder: aDecoder)!
        self.resetButton = UIButton(coder: aDecoder)!
        self.aboutButton = UIButton(coder: aDecoder)!
        self.preferencesButton = UIButton(coder: aDecoder)!
        self.shareButton = UIButton(coder: aDecoder)!
        
        self.trackerButton = UIButton(coder: aDecoder)!
        self.saveButton = UIButton(coder: aDecoder)!
        */
        self.interactableLayer = UIInteractableLayer(coder: aDecoder)!
        self.headerLayer = UIHeaderLayer(coder: aDecoder)!
        
        super.init(coder: aDecoder)!
        followUser = true
    }
    
    ///
    /// De initalize the ViewController.
    ///
    /// Current implementation removes notification observers
    ///
    deinit {
        print("*** deinit")
        removeNotificationObservers()
    }
   
    
    ///
    /// Initializes the view. It adds the UI elements to the view.
    ///
    /// All the UI is built programatically on this method. Interface builder is not used.
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        stopWatch.delegate = self
        
        //Because of the edges, iPhone X* is slightly different on the layout.
        //So, Is the current device an iPhone X?
        var isIPhoneX = false
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("device: IPHONE 5,5S,5C")
            case 1334:
                print("device: IPHONE 6,7,8 IPHONE 6S,7S,8S ")
            case 1920, 2208:
                print("device: IPHONE 6PLUS, 6SPLUS, 7PLUS, 8PLUS")
            case 2436:
                print("device: IPHONE X, IPHONE XS")
                isIPhoneX = true
            case 2688:
                print("device: IPHONE XS_MAX")
                isIPhoneX = true
            case 1792:
                print("device: IPHONE XR")
                isIPhoneX = true
            default:
                print("UNDETERMINED")
            }
        }
        
        // Watch communication session activation (available >iOS 9)
        if #available(iOS 9.0, *) {
            if WCSession.isSupported() {
                print("ViewController:: WCSession is supported")
                let session = WCSession.default
                session.delegate = self
                session.activate()
                print("ViewController:: WCSession activated")
            }
            else {
                print("ViewController:: WCSession is not supported")
            }
        }
        
        // Map autorotate configuration
        map.autoresizesSubviews = true
        map.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.autoresizesSubviews = true
        self.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        // Map configuration Stuff
        map.delegate = mapViewDelegate
        map.showsUserLocation = true
        let mapH: CGFloat = self.view.bounds.size.height - (isIPhoneX ? 0.0 : 20.0)
        map.frame = CGRect(x: 0.0, y: (isIPhoneX ? 0.0 : 20.0), width: self.view.bounds.size.width, height: mapH)
        map.isZoomEnabled = true
        map.isRotateEnabled = true
        //set the position of the compass.
        map.compassRect = CGRect(x: map.frame.width/2 - 18, y: isIPhoneX ? 105.0 : 70.0 , width: 36, height: 36)
        
        //If user long presses the map, it will add a Pin (waypoint) at that point
        map.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(ViewController.addPinAtTappedLocation(_:)))
        )
        
        //Each time user pans, if the map is following the user, it stops doing that.
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.stopFollowingUser(_:)))
        panGesture.delegate = self
        map.addGestureRecognizer(panGesture)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        //let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchGesture")
        //map.addGestureRecognizer(pinchGesture)
        
        //Preferences load
        let defaults = UserDefaults.standard
        if var tileServerInt = defaults.object(forKey: kDefaultsKeyTileServerInt) as? Int {
            // In version 1.5 one tileServer was removed, so some users may have selected a tileServer that no longer exists.
            tileServerInt = (tileServerInt >= GPXTileServer.count ? GPXTileServer.apple.rawValue : tileServerInt)
            print("** Preferences : setting saved tileServer \(tileServerInt)")
            map.tileServer = GPXTileServer(rawValue: tileServerInt)!
        } else {
            print("** Preferences: using default tileServer: Apple")
            map.tileServer = .apple
        }
        if let useCacheBool = defaults.object(forKey: kDefaultsKeyUseCache) as? Bool {
            print("** Preferences: setting saved useCache: \(useCacheBool)")
            map.useCache = useCacheBool
        }
        
        //
        // Config user interface
        //
        
        // Set default zoom
        let center = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: center, span: span)
        map.setRegion(region, animated: true)
        self.view.addSubview(map)
        
        addNotificationObservers()

        self.view.addSubview(headerLayer)
        headerLayer.setupLayer(with: map, view: view, isIPhoneX: isIPhoneX)
        
        map.addSubview(interactableLayer)
        interactableLayer.setupLayer(with: map, view: view, isIPhoneX: isIPhoneX)
    }
    
    ///
    /// Asks the system to notify the app on some events
    ///
    /// Current implementation requests the system to notify the app:
    ///
    ///  1. whenever it enters background
    ///  2. whenever it becomes active
    ///  3. whenever it will terminate
    ///
    func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(ViewController.didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
       
        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        
        notificationCenter.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }

    ///
    /// Removes the notification observers
    ///
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// returns a string with the format of current date dd-MMM-yyyy-HHmm' (20-Jun-2018-1133)
    ///
    
    func defaultFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy-HHmm"
        print("fileName:" + dateFormatter.string(from: Date()))
        return dateFormatter.string(from: Date())
    }
    
    ///
    /// UIGestureRecognizerDelegate required for stopFollowingUser
    ///
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Zoom gesture controls that follow user to
    func pinchGesture(_ gesture: UIPinchGestureRecognizer) {
        print("pinchGesture")
     /*   if gesture.state == UIGestureRecognizerState.Began {
            self.followUserBeforePinchGesture = self.followUser
            self.followUser = false
        }
        //return to back
        if gesture.state == UIGestureRecognizerState.Ended {
            self.followUser = self.followUserBeforePinchGesture
        }
        */
    }
    
    ///
    /// It adds a Pin (Waypoint/Annotation) to current user location.
    ///
    @objc func addPinAtMyLocation() {
        print("Adding Pin at my location")
        let waypoint = GPXWaypoint(coordinate: map.userLocation.coordinate)
        map.addWaypoint(waypoint)
        self.hasWaypoints = true
    }
    
    ///
    /// Triggered when follow Button is taped.
    //
    /// Trogles between following or not following the user, that is, automatically centering the map
    //  in current user´s position.
    ///
    @objc func followButtonTroggler() {
        self.followUser = !self.followUser
    }
    
    ///
    /// Triggered when reset button was tapped.
    ///
    /// It sets map to status .notStarted which clears the map.
    ///
    @objc func resetButtonTapped() {
        self.gpxTrackingStatus = .notStarted
    }
    

    ///
    /// Main Start/Pause Button was tapped.
    ///
    /// It sets the status to tracking or paused.
    ///
    @objc func trackerButtonTapped() {
        print("startGpxTracking::")
        switch gpxTrackingStatus {
        case .notStarted:
            gpxTrackingStatus = .tracking
        case .tracking:
            gpxTrackingStatus = .paused
        case .paused:
            //set to tracking
            gpxTrackingStatus = .tracking
        }
    }
    
    ///
    /// Triggered when user taps on save Button
    ///
    /// It prompts the user to set a name of the file.
    ///
    @objc func saveButtonTapped() {
        print("save Button tapped")
        // ignore the save button if there is nothing to save.
        if (gpxTrackingStatus == .notStarted) && !self.hasWaypoints {
            return
        }
        
        // save alert configuration and presentation
        let alertController = UIAlertController(title: "Save as", message: "Enter GPX session name", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.clearButtonMode = .always
            textField.text = self.lastGpxFilename.isEmpty ? self.defaultFilename() : self.lastGpxFilename
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            let filename = (alertController.textFields?[0].text!.utf16.count == 0) ? self.defaultFilename() : alertController.textFields?[0].text
            print("Save File \(String(describing: filename))")
            //export to a file
            let gpxString = self.map.exportToGPXString()
            GPXFileManager.save(filename!, gpxContents: gpxString)
            self.lastGpxFilename = filename!
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
    
    ///
    /// There was a memory warning. Right now, it does nothing but to log a line.
    ///
    override func didReceiveMemoryWarning() {
        print("didReceiveMemoryWarning");
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///
    /// Checks the location services status
    /// - Are location services enabled (access to location device wide)? If not => displays an alert
    /// - Are location services allowed to this app? If not => displays an alert
    ///
    /// - Seealso: displayLocationServicesDisabledAlert, displayLocationServicesDeniedAlert
    ///
    func checkLocationServicesStatus() {
        //Are location services enabled?
        if !CLLocationManager.locationServicesEnabled() {
            displayLocationServicesDisabledAlert()
            return
        }
        //Does the app have permissions to use the location servies?
        if !([.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())) {
            displayLocationServicesDeniedAlert()
            return
        }
    }
    ///
    /// Displays an alert that informs the user that location services are disabled.
    ///
    /// When location services are disabled is for all applications, not only this one.
    ///
    func displayLocationServicesDisabledAlert() {
        
        let alertController = UIAlertController(title: "Location services disabled", message: "Go to settings and enable location.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)

    }

    
    ///
    /// Displays an alert that informs the user that access to location was denied for this app (other apps may have access).
    /// It also dispays a button allows the user to go to settings to activate the location.
    ///
    func displayLocationServicesDeniedAlert() {
        if isDisplayingLocationServicesDenied {
            return // display it only once.
        }
        let alertController = UIAlertController(title: "Access to location denied", message: "On Location settings, allow always access to location for GPX Tracker ", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        isDisplayingLocationServicesDenied = false
    }

}

// MARK: StopWatchDelegate

///
/// Updates the `timeLabel` with the `stopWatch` elapsedTime.
/// In the main ViewController there is a label that holds the elapsed time, that is, the time that
/// user has been tracking his position.
///
///
extension ViewController: StopWatchDelegate {
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String) {
        interactableLayer.timeLabel.text = elapsedTimeString
    }
}

// MARK: PreferencesTableViewControllerDelegate

extension ViewController: PreferencesTableViewControllerDelegate {
    ///
    /// Updates the `tileServer` the map is using.
    ///
    /// If user enters preferences and he changes his preferences regarding the `tileServer`,
    /// the map of the main `ViewController` needs to be aware of it.
    ///
    /// `PreferencesTableViewController` informs the main `ViewController` through this delegate.
    ///
    func didUpdateTileServer(_ newGpxTileServer: Int) {
        print("** Preferences:: didUpdateTileServer: \(newGpxTileServer)")
        self.map.tileServer = GPXTileServer(rawValue: newGpxTileServer)!
    }
    
    ///
    /// If user changed the setting of using cache, through this delegate, the main `ViewController`
    /// informs the map to behave accordingly.
    ///
    func didUpdateUseCache(_ newUseCache: Bool) {
        print("** Preferences:: didUpdateUseCache: \(newUseCache)")
        self.map.useCache = newUseCache
    }
}

// MARK: location manager Delegate


extension ViewController: GPXFilesTableViewControllerDelegate {
    ///
    /// Loads the selected GPX File into the map.
    ///
    /// Resets whatever estatus was before.
    ///
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: GPXRoot) {
        //emulate a reset button tap
        self.resetButtonTapped()
        //println("Loaded GPX file", gpx.gpx())
        lastGpxFilename = gpxFilename
        //force reset timer just in case reset does not do it
        self.stopWatch.reset()
        //load data
        self.map.importFromGPXRoot(gpxRoot)
        //stop following user
        self.followUser = false
        //center map in GPX data
        self.map.regionToGPXExtent()
        self.gpxTrackingStatus = .paused
        
        interactableLayer.totalTrackedDistanceLabel.distance = self.map.totalTrackedDistance
        
    }
}

// MARK: CLLocationManagerDelegate


extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        headerLayer.coordsLabel.text = kNotGettingLocationText
        interactableLayer.signalAccuracyLabel.text = kUnknownAccuracyText
        interactableLayer.signalImageView.image = signalImage0
        let locationError = error as? CLError
        switch locationError?.code {
        case CLError.locationUnknown:
            print("Location Unknown")
        case CLError.denied:
            print("Access to location services denied. Display message")
            checkLocationServicesStatus()
        case CLError.headingFailure:
            print("Heading failure")
        default:
            print("Default error")
        }
  
    }
    
    ///
    /// Updates location accuracy and map information when user is in a new position
    ///
    ///
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //updates signal image accuracy
        let newLocation = locations.first!
        print("isUserLocationVisible: \(map.isUserLocationVisible) showUserLocation: \(map.showsUserLocation)")
        print("didUpdateLocation: received \(newLocation.coordinate) hAcc: \(newLocation.horizontalAccuracy) vAcc: \(newLocation.verticalAccuracy) floor: \(newLocation.floor?.description ?? "''") map.userTrackingMode: \(map.userTrackingMode.rawValue)")
        let hAcc = newLocation.horizontalAccuracy
        interactableLayer.signalAccuracyLabel.text = "±\(hAcc)m"
        if hAcc < kSignalAccuracy6 {
            interactableLayer.signalImageView.image = signalImage6
        } else if hAcc < kSignalAccuracy5 {
            interactableLayer.signalImageView.image = signalImage5
        } else if hAcc < kSignalAccuracy4 {
            interactableLayer.signalImageView.image = signalImage4
        } else if hAcc < kSignalAccuracy3 {
            interactableLayer.signalImageView.image = signalImage3
        } else if hAcc < kSignalAccuracy2 {
            interactableLayer.signalImageView.image = signalImage2
        } else if hAcc < kSignalAccuracy1 {
            interactableLayer.signalImageView.image = signalImage1
        } else{
            interactableLayer.signalImageView.image = signalImage0
        }
        
        //Update coordsLabel
        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
        let altFormat = String(format: "%.2f", newLocation.altitude)
        headerLayer.coordsLabel.text = "(\(latFormat),\(lonFormat)) · altitude: \(altFormat)m"
        
        
        //Update speed (provided in m/s, but displayed in km/h)
        var speedFormat: String
        if newLocation.speed < 0 {
            speedFormat = kUnknownSpeedText
        } else {
            speedFormat = String(format: "%.2f", (newLocation.speed * 3.6))
        }
        interactableLayer.speedLabel.text = "\(speedFormat) km/h"
        
        //Update Map center and track overlay if user is being followed
        if followUser {
            map.setCenter(newLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .tracking {
            print("didUpdateLocation: adding point to track (\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude))")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
            interactableLayer.totalTrackedDistanceLabel.distance = map.totalTrackedDistance
            interactableLayer.currentSegmentDistanceLabel.distance = map.currentSegmentDistance
        }
    }
    
    
    ///
    ///
    /// When there is a change on the heading (direction in which the device oriented) it makes a request to the map
    /// to updathe the heading indicator (a small arrow next to user location point)
    ///
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("ViewController::didUpdateHeading \(newHeading.trueHeading)")
        map.updateHeading(newHeading)
        
    }
}


// MARK: WCSessionDelegate

///
/// Handles file transfers from Apple Watch companion app
/// Should be non intrusive to UI, handling all in the background.

/// File received are automatically moved to default location which stores all GPX files
///
/// Only available > iOS 9
///
@available(iOS 9.0, *)
extension ViewController: WCSessionDelegate {
    
    // called when `WCSession` goes inactive
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("GPXFilesTableViewController:: WCSession has become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("GPXFilesTableViewController:: WCSession has deactivated")
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("GPXFilesTableViewController:: activationDidCompleteWithActivationState: session activated")
        case .inactive:
            print("GPXFilesTableViewController:: activationDidCompleteWithActivationState: session inactive")
        case .notActivated:
            print("GPXFilesTableViewController:: activationDidCompleteWithActivationState: session not activated, error:\(String(describing: error))")
            
        default: break
        }
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let fileName = file.metadata!["fileName"] as! String?
        
        // alert to display to notify user that file has been received.
        let controller = UIAlertController(title: "File Received from Apple Watch", message: "Received file: \"\(fileName!)\"", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) {
            (action) in
            print("ViewController:: Presented file received message from WatchConnectivity Session")
        }
        
        controller.addAction(action)
        
        DispatchQueue.global().sync {
            GPXFileManager.moveFrom(file.fileURL, fileName: fileName)
            print("ViewController:: Received file from WatchConnectivity Session")
        }
        
        self.present(controller, animated: true, completion: nil)
    }
}

