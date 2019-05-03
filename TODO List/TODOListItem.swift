//
//  TODOListItem.swift
//  TODO List
//
//  Created by Tom on 5/1/19.
//  Copyright © 2019 Towd47. All rights reserved.
//

import Foundation
import os.log

class TODOListItem {
    
    var itemName: String
    var itemDescription: String
    var date: Date
    var priority: Priority
    
    init?(itemName: String, itemDescription: String, priority: Priority, date: Date) {
        guard !itemName.isEmpty else {
            return nil
        }
        
        self.itemName = itemName
        self.itemDescription = itemDescription
        self.priority = priority
        self.date = date
    }
    
    convenience init?(itemName: String, itemDescription: String, priorityInt: Int, date: Date) {
        self.init(itemName: itemName, itemDescription: itemDescription, priority: Priority.init(rawValue: priorityInt)!, date: date)
    }
    
    func uniqueIdentifier() -> String {
        let uniqueID = "\(itemName), \(itemDescription), \(date.description), \(priority)"
        
        return uniqueID
    }
}

enum Priority: Int {
    case low = 0
    case medium = 1
    case high = 2
    case completed = -1
    
    func name() -> String {
        if self == Priority.low {
            return "low"
        }
        else if self == Priority.medium {
            return "medium"
        }
        else if self == Priority.completed {
            return "completed"
        }
        else {
            return "high"
        }
    }
    
    func value() -> Int {
        return self.rawValue
    }
}
