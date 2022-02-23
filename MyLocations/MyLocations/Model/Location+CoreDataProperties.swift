//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var locationDescription: String
    @NSManaged public var placemark: CLPlacemark?
    @NSManaged public var date: Date
    @NSManaged public var photoID: NSNumber?
    @NSManaged public var category: String

}

extension Location : Identifiable {

}
