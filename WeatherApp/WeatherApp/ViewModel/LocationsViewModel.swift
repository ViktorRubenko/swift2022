//
//  LocationsViewModel.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import Foundation
import CoreLocation

class LocationsViewModel: NSObject {
    var locations = Observable<[WeatherLocation?]>([nil])
    var temporaryLocation = Observable<CLLocation?>(nil)
    var temporaryPlaceName: String = " "
    var currentPlaceName = Observable<String>("Current Location")
    
    override init() {
        super.init()
        
        WeatherModel.shared.locations.bind {[weak self] locations in
            self?.locations.value = [nil] + locations
            print("UPDATE MODEL LOCATIONS")
            print(locations.compactMap({$0.placeName}))
        }
    }
    
    func loadLocations() {
        WeatherModel.shared.loadLocations()
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
