//
//  TagLocationViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import UIKit
import CoreData
import CoreLocation
import AudioToolbox

class CurrentLocationViewController: UIViewController, ManagedObjectContextProtocol {

    var managedObjectContext: NSManagedObjectContext!
    lazy var locationManager: CLLocationManager = {
        CLLocationManager()
    }()
    var location: CLLocation?
    var lastLocationError: Error?
    var updatingLocation = false
    
    lazy var geocoder: CLGeocoder = {
        CLGeocoder()
    }()
    var placemark: CLPlacemark?
    var updatingPlacemark = false
    var lastGeocodingError: Error?
    
    var timer: Timer?
    
    var containerView: CurrentLocationViewContainer!
    var messageLabel: UILabel!
    var latitudeLabel: UILabel!
    var longitudeLabel: UILabel!
    var latitudeValueLabel: UILabel!
    var longitudeValueLabel: UILabel!
    var tagButton: UIButton!
    var addressLabel: UILabel!
    
    var getLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get My Location", for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        button.sizeToFit()
        return button
    }()
    
    var logoVisible = false
    
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        button.sizeToFit()
        button.center.x = view.bounds.midX
        button.center.y = button.frame.size.height / 2 + 50
        return button
    }()
    
    var soundID: SystemSoundID = 0
    var topSafeInset = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        containerView = CurrentLocationViewContainer()
        
        messageLabel = containerView.messageLabel
        latitudeLabel = containerView.latitudeLabel
        longitudeLabel = containerView.longitudeLabel
        latitudeValueLabel = containerView.latitudeValueLabel
        longitudeValueLabel = containerView.longitudeValueLabel
        tagButton = containerView.tagButton
        addressLabel = containerView.addressLabel
        
        getLocationButton.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        tagButton.addTarget(self, action: #selector(tagLocation), for: .touchUpInside)
        setupSubviews()
        updateLabels()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        topSafeInset = view.safeAreaInsets.top
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

}

// MARK: - Actions
extension CurrentLocationViewController {
    @objc func getLocation() {
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        if logoVisible {
            hideLogoView()
        }
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
    }
    
    @objc func didTimeOut() {
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
        }
    }
    
    @objc func tagLocation() {
        let controller = LocationDetailsViewController()
        controller.managedObjectContext = managedObjectContext
        controller.coordinate = location!.coordinate
        controller.placemark = placemark
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Helper methods
extension CurrentLocationViewController {
    
    func setupSubviews() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(getLocationButton)
        view.addSubview(containerView)
        
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            getLocationButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            getLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
    
    func updateLabels() {
        if let location = location {
            latitudeValueLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeValueLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = " "
            longitudeLabel.isHidden = false
            latitudeLabel.isHidden = false
            messageLabel.isHidden = false

            
            if let placemark = placemark {
                addressLabel.text = String(placemark)
            }
        } else {
            latitudeValueLabel.text = " "
            longitudeValueLabel.text = " "
            tagButton.isHidden = true
            addressLabel.text = " "
            longitudeLabel.isHidden = true
            latitudeLabel.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Updating location..."
            } else {
                statusMessage = " "
                showLogoView()
            }
            messageLabel.text = statusMessage
        }
        configureGetLocationButton()
    }
    
    func configureGetLocationButton() {
        let spinnerTag = 1000
        if updatingLocation {
            getLocationButton.setTitle("Stop", for: .normal)
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(style: .medium)
                spinner.center = addressLabel.center
                spinner.center.y = spinner.bounds.size.width / 2 + topSafeInset
                spinner.startAnimating()
                spinner.tag = spinnerTag
                view.addSubview(spinner)
            }
        } else {
            getLocationButton.setTitle("Get My Location", for: .normal)
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            updatingLocation = true
            
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false)
        }
    }
    
    func showLogoView() {
        if !logoVisible {
            logoVisible = true
            containerView.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        if !logoVisible { return }
        logoVisible = false
        containerView.isHidden = false
    
        containerView.center.x = view.bounds.size.width * 2
        
        let centerX = view.bounds.midX
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = .forwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = .forwards
        logoMover.duration = 0.6
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.delegate = self
        logoButton.layer.add(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = .forwards
        logoRotator.duration = 0.6
        logoRotator.fromValue = 0.0
        logoRotator.toValue = Double.pi * -2
        logoRotator.timingFunction = CAMediaTimingFunction(name: .easeIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
    }
    
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let status = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            if status != kAudioServicesNoError {
                print("Error code \(status) loading sound: \(path)")
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }
}
// MARK: - CLLocationManager Delegate
extension CurrentLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = location.distance(from: newLocation)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            location = newLocation
            lastLocationError = nil
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
                if distance > 0 {
                    // force to update placemark for new final location
                    updatingPlacemark = false
                }
            }
            
            if !updatingPlacemark {
                updatingPlacemark = true
                geocoder.reverseGeocodeLocation(newLocation) { [weak self] placemarks, error in
                    if error == nil, let places = placemarks, !places.isEmpty {
                        if self?.placemark == nil {
                            // FIRST TIME
                            self?.playSoundEffect()
                        }
                        self?.placemark = places.last!
                    } else {
                        self?.placemark = nil
                    }
                    self?.updatingPlacemark = false
                    self?.updateLabels()
                }
            }
            
            updateLabels()
        } else if distance < 1 {
            let timeInvertal = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInvertal > 10 {
                stopLocationManager()
                updateLabels()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
}
// MARK: - CAAanimationDelegate
extension CurrentLocationViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
}
