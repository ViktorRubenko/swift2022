//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Victor Rubenko on 14.02.2022.
//

import Foundation
import UserNotifications


class ChecklistItem: Codable {
    var text: String
    var checked: Bool
    var dueDate: Date
    var shouldRemind: Bool
    private(set) var itemID: Int
    
    init(text: String, checked: Bool = false, dueDate: Date = Date(), shouldRemind: Bool = false) {
        self.text = text
        self.checked = checked
        self.dueDate = dueDate
        self.shouldRemind = shouldRemind
        self.itemID = DataModel.nextChecklistItemID()
    }
    
    deinit {
        removeNotification()
    }
    
    func scheduleNotification() {
        removeNotification()
        if shouldRemind && dueDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Reminder:"
            content.body = self.text
            content.sound = .default
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: self.dueDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: String(self.itemID), content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
            
            print("Scheduled: \(request) for itemID: \(self.itemID)")
        }
    }
    
    func removeNotification() {
        if !shouldRemind {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(self.itemID)])
        }
    }
}
