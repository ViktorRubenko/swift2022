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
    
    var locations = Observable<[WeatherLocation]>([])
    
    private init() {}
    
    func loadLocations() {
        do {
            print("LOAD LOCATIONS")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
            let locations = try context.fetch(fetchRequest)
            self.locations.value = locations
            print(locations.compactMap({$0.placeName}))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func add(placeName: String, location: CLLocation) {
        let weatherLocation = WeatherLocation(context: context)
        weatherLocation.placeName = placeName
        weatherLocation.longitude = location.coordinate.longitude
        weatherLocation.latitude = location.coordinate.latitude
        weatherLocation.index = Int16(locations.value.count)
        locations.value.append(weatherLocation)
        save()
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func remove(_ index: Int) {
        let weatherLocation = locations.value[index]
        context.delete(weatherLocation)
        locations.value.remove(at: index)
    }
    
    func move(_ source: Int, _ destination: Int) {
        for weatherLocation in locations.value {
            if weatherLocation.index == source {
                continue
            }
            if destination > source && weatherLocation.index <= destination  && weatherLocation.index > source {
                weatherLocation.index -= 1
                continue
            }
            if source > destination && weatherLocation.index > destination && weatherLocation.index < source {
                weatherLocation.index += 1
                continue
            }
        }
        locations.value[source].index = Int16(destination)
        locations.value = locations.value.sorted { $0.index < $1.index }
        save()
    }
}
