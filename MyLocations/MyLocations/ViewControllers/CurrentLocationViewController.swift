//
//  TagLocationViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import UIKit
import CoreData
import CoreLocation

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
    
    var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var latitudeLabel: UILabel = {
        let label = UILabel()
        label.text = "Latitude:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var longitudeLabel: UILabel = {
        let label = UILabel()
        label.text = "Longitude:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var latitudeValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var longitudeValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var addressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    var tagButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tag Location", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    var getLocationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get My Location", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        getLocationButton.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        tagButton.addTarget(self, action: #selector(tagLocation), for: .touchUpInside)
        setupSubviews()
        updateLabels()
    
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
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
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
        view.addSubview(latitudeLabel)
        view.addSubview(longitudeLabel)
        view.addSubview(latitudeValueLabel)
        view.addSubview(longitudeValueLabel)
        view.addSubview(addressLabel)
        view.addSubview(messageLabel)
        view.addSubview(tagButton)
        view.addSubview(getLocationButton)
        
        messageLabel.text = "(Message Label)"
        longitudeValueLabel.text = "(Longitude goes here)"
        latitudeValueLabel.text = "(Latitude goes here)"
        addressLabel.text = "(Address goes here)"
        tagButton.isHidden = true
        
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            messageLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: latitudeLabel.topAnchor, constant: -24),
            
            latitudeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            latitudeLabel.bottomAnchor.constraint(equalTo: longitudeLabel.topAnchor, constant: -8),
            latitudeLabel.trailingAnchor.constraint(equalTo: latitudeValueLabel.leadingAnchor, constant: -16),
            
            longitudeLabel.leadingAnchor.constraint(equalTo: latitudeLabel.leadingAnchor),
            longitudeLabel.trailingAnchor.constraint(equalTo: longitudeValueLabel.leadingAnchor, constant: -16),
            
            latitudeValueLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            latitudeValueLabel.topAnchor.constraint(equalTo: latitudeLabel.topAnchor),
            
            longitudeValueLabel.topAnchor.constraint(equalTo: longitudeLabel.topAnchor),
            longitudeValueLabel.trailingAnchor.constraint(equalTo: latitudeValueLabel.trailingAnchor),
            
            addressLabel.topAnchor.constraint(equalTo: longitudeLabel.bottomAnchor, constant: 24),
            addressLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            tagButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            tagButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 24),
            
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
            
            if let placemark = placemark {
                addressLabel.text = String(placemark)
            }
        } else {
            latitudeValueLabel.text = ""
            longitudeValueLabel.text = ""
            tagButton.isHidden = true
            addressLabel.text = ""
            
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
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
        configureGetLocationButton()
    }
    
    func configureGetLocationButton() {
        if updatingLocation {
            getLocationButton.setTitle("Stop", for: .normal)
        } else {
            getLocationButton.setTitle("Get My Location", for: .normal)
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
}

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
                    if error == nil, let places = placemarks {
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
