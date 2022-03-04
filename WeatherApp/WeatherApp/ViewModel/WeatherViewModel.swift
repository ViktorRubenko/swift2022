//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import Foundation
import CoreLocation
import UIKit

enum WeatherDataError: Error {
    case locationTimeOut
    case locationServicesDisabled
    case unknown
}

class WeatherViewModel: NSObject {
    private var placemark: CLPlacemark?
    private var location: CLLocation?
    private var weatherDataResponse: WeatherResponse?
    private lazy var locationManager: CLLocationManager = { CLLocationManager() }()
    private lazy var geocoder: CLGeocoder = { CLGeocoder() }()
    private var timer: Timer?
    private var isUpdatingPlacemark = false
    
    var placeName = Observable<String>(" ")
    var weatherData = Observable<WeatherData?>(nil)
    var weatherError = Observable<WeatherDataError?>(nil)
    
    override init() {
        super.init()
    }
    
}
// MARK: - Helper Methods
extension WeatherViewModel {
    func updateLocation() {
        weatherError.value = nil
        // Check location services
        let authStatus = locationManager.authorizationStatus
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            weatherError.value = .locationServicesDisabled
            return
        default:
            location = nil
            placemark = nil
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
        
        if let location = location {
            WeatherDataManager.shared.weatherDataAt(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude) { result in
                    switch result {
                    case .success(let weatherResponse):
                        self.weatherData.value = WeatherData(weatherResponse: weatherResponse)
                    case .failure(_):
                        self.weatherError.value = .unknown
                    }
                }
        }
    }
    
    @objc private func didTimeOut() {
        if location == nil {
            stopLocationManager()
            weatherError.value = .locationTimeOut
        }
    }
}
// MARK: - LocationManagerDelegate
extension WeatherViewModel: CLLocationManagerDelegate {
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
                
                if distance > 0 {
                    isUpdatingPlacemark = false
                }
            }
            
            // Get placemark for new location
            if !isUpdatingPlacemark {
                isUpdatingPlacemark = true
                
                geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in
                    if error == nil, let places = placemarks, !places.isEmpty {
                        self.placemark = places.last!
                        self.placeName.value = String(places.last!)
                    } else {
                        self.placemark = nil
                    }
                    self.isUpdatingPlacemark = false
                }
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
