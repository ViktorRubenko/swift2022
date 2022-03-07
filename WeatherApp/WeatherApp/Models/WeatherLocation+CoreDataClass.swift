//
//  WeatherLocation+CoreDataClass.swift
//  
//
//  Created by Victor Rubenko on 07.03.2022.
//
//

import Foundation
import CoreData
import CoreLocation

@objc(WeatherLocation)
public class WeatherLocation: NSManagedObject {

    var location: CLLocation {
        CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}
