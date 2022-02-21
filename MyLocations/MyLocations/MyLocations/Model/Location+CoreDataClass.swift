//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Victor Rubenko on 20.02.2022.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject {

}

extension Location: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var title: String? {
        locationDescription.isEmpty ? "(No Description)" : locationDescription
    }
    
    public var subtitle: String? {
        return category
    }
}
