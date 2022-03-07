//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import Foundation
import CoreLocation
import UIKit

enum WeatherError: Error {
    case networkServiceError
    case geocoderServiceError
    case locationServiceError
    case unknown
}

class WeatherViewModel: NSObject {
    var placeName = Observable<String>(" ")
    var weatherResponse = Observable<WeatherResponse?>(nil)
    var weatherError = Observable<WeatherError?>(nil)
    private var location: CLLocation? {
        didSet {
            if location != nil {
                updateForecast()
                updatePlaceName()
            } else {
                weatherError.value = .locationServiceError
            }
        }
    }
    
    init(placeName: String? = nil, location: CLLocation? = nil) {
        if let location = location {
            self.location = location
        }
        if let placeName = placeName {
            self.placeName.value = placeName
        }
    }
    
    func updatePlaceName() {
        if let location = location {
            let geocoder = GeocodingManager()
            geocoder.getPlacemark(location) { [weak self] placemark in
                if let placemark = placemark {
                    self?.placeName.value = String(placemark)
                }
            }
        }
    }
    
    func updateForecast() {
        if let location = location {
            WeatherNetworkManager.shared.weatherDataAt(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude) { result in
                    switch result {
                    case .success(let weatherResponse):
                        self.weatherResponse.value = weatherResponse
                    case .failure(_):
                        self.weatherError.value = .networkServiceError
                    }
                }
        }
    }
    
    func updateLocation() {
        let locationServiceManager = LocationServiceManager(
            desiredAccuracy: kCLLocationAccuracyKilometer) {[weak self] location in
                if let location = location {
                    self?.location = location
                } else {
                    self?.weatherError.value = .locationServiceError
                }
            }
        locationServiceManager.getLocation()
    }
}
