//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Victor Rubenko on 14.02.2022.
//

import Foundation


class ChecklistItem {
    var text = ""
    var checked = false
    
    init(text: String, checked: Bool = false) {
        self.text = text
        self.checked = checked
    }
}
