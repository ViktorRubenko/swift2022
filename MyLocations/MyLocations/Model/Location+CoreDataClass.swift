//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//
//

import Foundation
import CoreData
import CoreLocation
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
        category
    }
}

extension Location {
    var hasPhoto: Bool {
        photoID != nil
    }
    
    var photoURL: URL? {
        if hasPhoto {
            let filename = "Photo-\(photoID!.intValue).jpg"
            return applicationDocumentsDirectory().appendingPathComponent(filename)
        }
        return nil
    }
    
    var photoImage: UIImage? {
        if hasPhoto {
            return UIImage(contentsOfFile: photoURL!.path)
        }
        return nil
    }
    
    class func nextPhotoID() -> Int {
        UserDefaults.standard.register(defaults: ["PhotoID": 0])
        let currentID = UserDefaults.standard.integer(forKey: "PhotoID") + 1
        UserDefaults.standard.set(currentID, forKey: "PhotoID")
        return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL!)
            } catch {
                print("Error removing file: \(error.localizedDescription)")
            }
        }
    }
}
