//
//  Extensions.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import Foundation
import CoreLocation

extension String {
    init(_ placemark: CLPlacemark) {
        var result = ""
        if placemark.thoroughfare != nil {
            result += placemark.thoroughfare! + ", "
        }
        if placemark.subThoroughfare != nil {
            result += placemark.subThoroughfare!
        }
        if placemark.locality != nil {
            result += result.isEmpty ? "" : "\n" + placemark.locality! + ", "
        }
        if placemark.administrativeArea != nil {
            result += placemark.administrativeArea! + ", "
        }
        if placemark.postalCode != nil {
            result += placemark.postalCode!
        }
        
        self = result
    }
}

extension String {
    init(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd hh:mm"
        self = dateFormatter.string(from: date)
    }
}
