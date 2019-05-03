//
//  CoreDataHandler.swift
//  TODO List
//
//  Created by Tom on 5/3/19.
//  Copyright © 2019 Towd47. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataHandler {
    
    var savedItems: [NSManagedObject]
    var managedContext: NSManagedObjectContext?
    
    init() {
        savedItems = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TODO_Item")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            savedItems = try managedContext!.fetch(fetchRequest)
            for savedItem in savedItems {
                if itemFromNSManagedObject(savedItem) == nil {
                    deleteNSManagedObject(savedItem)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func populateSavedItems() -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
    
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TODO_Item")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let savedItems = try managedContext.fetch(fetchRequest)
            for savedItem in savedItems {
                if itemFromNSManagedObject(savedItem) == nil {
                    deleteNSManagedObject(savedItem)
                }
            }
            return savedItems
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
    
    func itemFromNSManagedObject(_ nsObject: NSManagedObject) -> TODOListItem? {
        
        guard let itemName = nsObject.value(forKey: "name") as? String else {
            return nil
        }
        guard let date = nsObject.value(forKey: "date") as? Date else {
            return nil
        }
        let itemDescription = nsObject.value(forKey: "itemDescription") as? String ?? ""
        let priority = nsObject.primitiveValue(forKey: "priority") as! Int
        
        return TODOListItem.init(itemName: itemName, itemDescription: itemDescription, priorityInt: priority, date: date)
    }
    
    func itemFromNSManagedObject(row: Int) -> TODOListItem? {
        let nsObject = savedItems[row]
        
        guard let itemName = nsObject.value(forKey: "name") as? String else {
            return nil
        }
        guard let date = nsObject.value(forKey: "date") as? Date else {
            return nil
        }
        let itemDescription = nsObject.value(forKey: "itemDescription") as? String ?? ""
        let priority = nsObject.primitiveValue(forKey: "priority") as! Int
        
        return TODOListItem.init(itemName: itemName, itemDescription: itemDescription, priorityInt: priority, date: date)
    }
    
    func saveItem(atRow row: Int, item: TODOListItem) {
        
        let savedItem: NSManagedObject
        
        if row == -1 {
            let entity = NSEntityDescription.entity(forEntityName: "TODO_Item", in: managedContext!)!
            savedItem = NSManagedObject(entity: entity, insertInto: managedContext)
        }
        else {
            savedItem = savedItems[row]
        }
        
        savedItem.setValue(item.itemName, forKeyPath: "name")
        savedItem.setValue(item.date, forKey: "date")
        savedItem.setValue(item.priority.value(), forKey: "priority")
        savedItem.setValue(item.itemDescription, forKey: "itemDescription")
        savedItem.setValue(item.uniqueIdentifier(), forKey: "uniqueID")
        
        do {
            if row == -1 {
                savedItems.append(savedItem)
            }
            try managedContext!.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteNSManagedObject(atRow row: Int) {
        let nsObject = savedItems[row]
        managedContext!.delete(nsObject)
        do {
            try managedContext!.save()
            savedItems.remove(at: row)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteNSManagedObject(_ nsObject: NSManagedObject) {
        managedContext!.delete(nsObject)
        do {
            try managedContext!.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // Sort functions for savedItems
    
    func sort(sortedBy: String) {
        if sortedBy == "Priority" {
            sortByPriority()
        }
        else {
            sortByDate()
        }
    }
    
    func sortByPriority() {
        savedItems.sort {
            let item0 = itemFromNSManagedObject($0)!
            let item1 = itemFromNSManagedObject($1)!
            
            if (item0.priority == item1.priority) {
                return item0.date < item1.date
            }
            else {
                return item0.priority.value() > item1.priority.value()
            }
        }
    }
    
    func sortByDate() {
        savedItems.sort {
            let item0 = itemFromNSManagedObject($0)!
            let item1 = itemFromNSManagedObject($1)!
            
            if (item0.priority.value() < 0 || item1.priority.value() < 0) {
                return item0.priority.value() > item1.priority.value()
            }
            if (item0.date == item1.date) {
                return item0.priority.value() > item1.priority.value()
            }
            else {
                return item0.date < item1.date
            }
        }
    }
}
