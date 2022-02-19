//
//  Extensions.swift
//  MyLocations
//
//  Created by Victor Rubenko on 19.02.2022.
//

import Foundation
import CoreLocation
import UIKit

extension String {
    init(_ placemark: CLPlacemark) {
        var line1 = ""
        if let tmp = placemark.subThoroughfare {
            line1 += tmp + " "
        }
        if let tmp = placemark.thoroughfare {
            line1 += tmp
        }
        
        var line2 = ""
        if let tmp = placemark.locality {
            line2 += tmp + " "
        }
        if let tmp = placemark.administrativeArea {
            line2 += tmp + " "
        }
        if let tmp = placemark.postalCode {
            line2 += tmp
        }
        
        self.init(line1 + "\n" + line2)
    }
}
