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
    var iconName: String = "No Icon"
    
    init(name: String) {
        self.name = name
    }
    
    convenience init(name: String, icon: String) {
        self.init(name: name)
        self.iconName = icon
    }
    
    func countUncheckedItems() -> Int {
        items.reduce(0) { partialResult, item in
            partialResult + (item.checked ? 0 : 1)
        }
    }
    
    func sortChecklistItems() {
        items.sort { $0.dueDate < $1.dueDate }
    }
}
