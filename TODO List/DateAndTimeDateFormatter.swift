//
//  DateFormatter.swift
//  TODO List
//
//  Created by Tom on 5/3/19.
//  Copyright © 2019 Towd47. All rights reserved.
//

import Foundation

class DateAndTimeDateFormatter {
    static func formateDateWithTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma - MMMM d, yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    static func formateDateWithoutTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        return dateFormatter.string(from: date)
    }
}
