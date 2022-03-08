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
   
    
    override init() {
        super.init()
        
        WeatherModel.shared.locations.bind {[weak self] locations in
            self?.locations.value = [nil] + locations
            print("UPDATE MODEL LOCATIONS")
        }
    }
    
    func loadLocations() {
        WeatherModel.shared.loadLocations()
    }
}
