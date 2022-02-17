//
//  DataModel.swift
//  Checklists
//
//  Created by Victor Rubenko on 15.02.2022.
//

import Foundation


class DataModel {
    var lists = [Checklist]()
    
    var indexOfSelectedChecklist: Int {
        get {
            UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
        }
    }
    
    init() {
        loadChecklists()
        registerDefaults()
    }
    
    func registerDefaults() {
        UserDefaults.standard.register(defaults: ["ChecklistIndex": -1, "ChecklistItemID": 0])
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func saveChecklists() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(lists)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }
    
    func loadChecklists() {
        let decoder = PropertyListDecoder()
        do {
            let data = try Data(contentsOf: dataFilePath())
            lists = try decoder.decode([Checklist].self, from: data)
            sortChecklists()
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
        }
    }
    
    func sortChecklists() {
        lists.sort(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending })
    }
    
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        return itemID
    }
}
