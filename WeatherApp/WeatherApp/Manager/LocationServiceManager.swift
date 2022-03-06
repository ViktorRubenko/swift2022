//
//  LocationServiceManager.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import Foundation
import CoreLocation

enum LocationError: Error {
    case locationTimeOut
    case locationServicesDisabled
    case unknown
}

class LocationServiceManager: NSObject {
    private lazy var locationManager: CLLocationManager = {
        CLLocationManager()
    }()
    private var locationError: LocationError?
    private var timer: Timer?
    private var timeout: Int!
    private var location: CLLocation?
    var completion: ((CLLocation?) -> Void)!
    
    
    init(desiredAccuracy: CLLocationAccuracy, timeout: Int = 60, completion: @escaping ((CLLocation?) -> Void)) {
        super.init()
        locationManager.desiredAccuracy = desiredAccuracy
        self.timeout = timeout
        self.completion = completion
    }
    
    func getLocation() {
        // Check location services
        let authStatus = locationManager.authorizationStatus
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            getLocation()
        case .restricted, .denied:
            return
        default:
            location = nil
            startLocationManager()
        }
    }
    
    private func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false)
        }
    }
    
    private func stopLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        completion(location)
    }
    
    @objc private func didTimeOut() {
        if location == nil {
            locationError = .locationTimeOut
        }
        stopLocationManager()
        completion(location)
    }
}
// MARK: - LocationManagerDelegate
extension LocationServiceManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        let newLocation = locations.last!
        
        if newLocation.horizontalAccuracy < 0 {
            // invalid location
            return
        }
        
        if let location = location {
            distance = location.distance(from: newLocation)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                // Find satisfying location
                stopLocationManager()
            }
        } else if distance < 1 {
            // If newLocation doesnt change a lot => stop
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                stopLocationManager()
            }
        }
    }
}

