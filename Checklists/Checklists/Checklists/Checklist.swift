//
//  Checklist.swift
//  Checklists
//
//  Created by Victor Rubenko on 15.02.2022.
//

import Foundation


class Checklist: Codable {
    var name: String
    var items = [ChecklistItem]()
    
    init(name: String) {
        self.name = name
    }
}
