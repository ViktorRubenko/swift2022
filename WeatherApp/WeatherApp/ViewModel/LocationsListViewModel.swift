//
//  LocationsListViewModel.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 08.03.2022.
//

import Foundation
import CoreLocation

class LocationsListViewModel {
    var temporaryLocation = Observable<CLLocation?>(nil)
    var temporaryPlaceName: String = " "
    var currentPlaceName = Observable<String>("Current Location")
    var placeNames = Observable<[String]>([])
    
    init() {
        WeatherModel.shared.placeNames.bind { [weak self] placeNames in
            print("UPDACE PLACENAMES")
            self?.placeNames.value = ["Current Place"] + placeNames
        }
        placeNames.value = ["Current Place"] + WeatherModel.shared.placeNames.value
    }
    
    func saveTemporary() {
        if let temporaryLocation = temporaryLocation.value {
            WeatherModel.shared.add(placeName: temporaryPlaceName, location: temporaryLocation)
            print("save")
        }
    }
    
    func remove(_ index: Int) {
         WeatherModel.shared.remove(index-1)
    }
    
    func findByPlaceName(placeName: String) {
        temporaryPlaceName = placeName
        let geocodingManager = GeocodingManager()
        geocodingManager.getLocation(temporaryPlaceName) { [weak self] location in
            if let location = location {
                self?.temporaryLocation.value = location
            }
        }
    }
    
    func move(_ source: Int, _ destination: Int) {
        WeatherModel.shared.move(source - 1, destination - 1)
    }
    
    func updateCurrentPlaceName() {
        let locationServiceManager = LocationServiceManager(
            desiredAccuracy: kCLLocationAccuracyKilometer) {[weak self] location in
                if let location = location {
                    let geocoder = GeocodingManager()
                    geocoder.getPlacemark(location) { [weak self] placemark in
                        if let placemark = placemark {
                            self?.currentPlaceName.value = String(placemark)
                        }
                    }
                } else {
                    print("Error")
                }
            }
        locationServiceManager.getLocation()
    }
}
