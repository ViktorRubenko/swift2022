//
//  ManagedObjectContextProtocol.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import UIKit
import CoreData

protocol ManagedObjectContextProtocol: UIViewController {
    var managedObjectContext: NSManagedObjectContext! { get set }
}
