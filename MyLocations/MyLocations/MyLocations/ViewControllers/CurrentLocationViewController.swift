//
//  ViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 19.02.2022.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, managedObjectContextProtocol {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    var timer: Timer?
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func showLocationServiceDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Service Disabled",
            message: "Please enable location services for this app in Settings",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func getLocation() {
        if updatingLocation {
            stopLocationManager()
            return
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        // Ask permission
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .restricted || authStatus == .denied {
            showLocationServiceDeniedAlert()
            return
        }
        startLocationManager()
    }
    
    @IBAction func tagLocation() {
        let controller = LocationDetailsViewController()
        controller.coordinate = location!.coordinate
        controller.placemark = placemark
        controller.managedObjectContext = managedObjectContext
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Helper Methods
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = String(placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            tagButton.isHidden = true
            
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
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location to Start'"
            }
            messageLabel.text = statusMessage
        }
        configureGetButton()
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    func stopLocationManager() {
        if updatingLocation, let timer = timer {
            timer.invalidate()
        }
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        updatingLocation = false
    }
    
    func configureGetButton() {
        getButton.setTitle(updatingLocation ? "Stop" : "Get My Location", for: .normal)
    }
    
    @objc func didTimeOut() {
        // raise if can not find location for 60 sec
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(
                domain: "MyLocationErrorDomain",
                code: 1,
                userInfo: nil
            )
            updateLabels()
        }
    }
}

extension CurrentLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
    
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            // non valid accuracy
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            // new location has better accuracy
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if location!.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            if !performingReverseGeocoding {
                geocoder.reverseGeocodeLocation(location!) {[weak self] placemarks, error in
                    if error == nil, let places = placemarks, !places.isEmpty {
                        self?.placemark = places.last
                    } else {
                        self?.placemark = nil
                        if let error = error {
                            self?.lastGeocodingError = error
                        }
                    }
                    
                    self?.performingReverseGeocoding = false
                    self?.updateLabels()
                }
            }
        } else if distance < 1 {
            // distance < 1 => location is not nill and location.accuracy < newLocation.accuracy
            // cant find better location => stop
            let timeInterval  = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("Foce stop locationManager")
                stopLocationManager()
                updateLabels()
            }
        }
    }
}
