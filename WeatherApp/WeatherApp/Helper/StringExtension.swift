//
//  StringExtension.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import Foundation
import CoreLocation

extension String {
    init(_ placemark: CLPlacemark) {
        var result = ""
        
        if let city = placemark.locality {
            result = city
        }
        
        self = result
    }
}
