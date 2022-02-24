//
//  Extensions.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import Foundation
import CoreLocation
import UIKit

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

extension UIImage {
    func resized(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
