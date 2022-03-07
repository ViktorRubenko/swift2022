//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import Foundation
import CoreLocation
import CoreData

class WeatherModel {
    static let shared = WeatherModel()
    
    var context: NSManagedObjectContext!
    private let fetchRequest: NSFetchRequest<WeatherLocation> = WeatherLocation.fetchRequest()
    
    var locations = Observable<[WeatherLocation?]>([nil])
    
    private init() {}
    
    func loadLocations() {
        do {
            let locations = try context.fetch(fetchRequest)
            print(locations.count)
            self.locations.value = [nil] + locations
            print(self.locations.value.count)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func add(placeName: String, location: CLLocation) {
        let weatherLocation = WeatherLocation(context: context)
        weatherLocation.placeName = placeName
        weatherLocation.longitude = location.coordinate.longitude
        weatherLocation.latitude = location.coordinate.latitude
        
        do {
            try context.save()
            locations.value.append(weatherLocation)
        } catch {
            print(error.localizedDescription)
        }
    }
}
