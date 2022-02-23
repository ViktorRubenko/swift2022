//
//  Functions.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import Foundation


func applicationDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
