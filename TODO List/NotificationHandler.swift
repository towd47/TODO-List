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

enum NotificationCategory: String {
    case news
}

enum NotificationCategoryAction: String {
    case view
    case complete
}

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
        @escaping () -> Void) {
        
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        if let category = NotificationCategory(rawValue: categoryIdentifier) {
            switch category {
            case .news:
                handleNews(response: response)
            }
        }
        completionHandler()
    }
    
    private func handleNews(response: UNNotificationResponse) {
        let message: String
        
        if let actionType = NotificationCategoryAction(rawValue: response.actionIdentifier) {
            switch actionType {
            case .complete: message = "You choose Vote!"
            case .view: message = "You choose Cancel!"
            }
        } else {
            message = ""
        }
        
        if !message.isEmpty {
            showAlert(message: message)
        }
    }
    
    private func showAlert(message: String) {
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            vc.present(alert, animated: true)
        }
    }
}
