//
//  NotificationHandler.swift
//  TODO List
//
//  Created by Tom on 5/3/19.
//  Copyright © 2019 Towd47. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import CoreData

enum NotificationCategory: String {
    case completeCategory = "completeCategory"
}

enum NotificationCategoryAction: String {
    case view
    case complete
}

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
        @escaping () -> Void) {
        
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        if let category = NotificationCategory(rawValue: categoryIdentifier) {
            switch category {
            case .completeCategory:
                handleComplete(response: response)
            }
        }
        completionHandler()
    }
    
    private func handleComplete(response: UNNotificationResponse) {
        if let actionType = NotificationCategoryAction(rawValue: response.actionIdentifier) {
            switch actionType {
            case .complete:
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                
                let managedContext = appDelegate.persistentContainer.viewContext
                
                
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TODO_Item")
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let savedItems = try managedContext.fetch(fetchRequest)
                    for savedItem in savedItems {
                        let item = savedItem.value(forKey: "uniqueID") as? String ?? ""
                        if item == response.notification.request.identifier {
                            savedItem.setValue(Priority.completed.value(), forKey: "priority")
                            break
                        }
                    }
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
            case .view:
                print("view")
            }
        }
    }
}
