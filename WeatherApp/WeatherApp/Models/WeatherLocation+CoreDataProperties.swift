//
//  WeatherLocation+CoreDataProperties.swift
//  
//
//  Created by Victor Rubenko on 07.03.2022.
//
//

import Foundation
import CoreData


extension WeatherLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherLocation> {
        return NSFetchRequest<WeatherLocation>(entityName: "WeatherLocation")
    }

    @NSManaged public var placeName: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var index: Int16

}
