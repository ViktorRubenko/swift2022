//
//  GeocodingManager.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import Foundation
import CoreLocation

final class GeocodingManager {
    var placemark = Observable<CLPlacemark?>(nil)
    var isBusy = false
    private lazy var geocoder: CLGeocoder = { CLGeocoder() }()
    
    init() {}
    
    func getPlacemark(_ location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if error == nil, let places = placemarks, !places.isEmpty {
                completion(places.first!)
            } else {
                completion(nil)
            }
        }
    }
    
}
