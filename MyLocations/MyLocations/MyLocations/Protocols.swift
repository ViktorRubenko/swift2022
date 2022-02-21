//
//  Protocols.swift
//  MyLocations
//
//  Created by Victor Rubenko on 21.02.2022.
//

import Foundation
import CoreData


protocol managedObjectContextProtocol {
    var managedObjectContext: NSManagedObjectContext! { get set }
}
