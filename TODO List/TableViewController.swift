//
//  ViewController.swift
//  TODO List
//
//  Created by Tom on 5/1/19.
//  Copyright © 2019 Towd47. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var todoTable: UITableView!
    
    var savedItems: [NSManagedObject] = []
    var managedContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "TODO List"
        
        todoTable.rowHeight = 90;
        
        populateSavedItems()
    }
    
    func populateSavedItems() {
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
                    deleteNSManagedObject(savedItem, context: managedContext!)
                }
            }
            todoTable.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        sortByPriority()
    }
    
    // List Sorting
    
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
            
            if (item0.date == item1.date) {
                return item0.priority.value() > item1.priority.value()
            }
            else {
                return item0.date < item1.date
            }
        }
    }
    
    // Table functions
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return savedItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let item = itemFromNSManagedObject(savedItems[indexPath.row]) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TODOItemViewCell", for: indexPath) as? TODOItemViewCell else {
                fatalError("Cell is not TODOItemViewCell")
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            cell.itemNameLabel.text = item.itemName
            
            cell.dateLabel.text = dateFormatter.string(from: item.date)
            cell.dateLabel.backgroundColor = colorForDate(item.date)
            cell.dateLabel.layer.borderColor = UIColor.darkGray.cgColor
            cell.dateLabel.layer.borderWidth = 1
            
            cell.priorityLabel.text = item.priority.name()
            cell.priorityLabel.backgroundColor = colorForPriority(item.priority)
            cell.priorityLabel.layer.borderColor = UIColor.darkGray.cgColor
            cell.priorityLabel.layer.borderWidth = 1
                        
            return cell
        }
        fatalError("faild getting item from managedObject")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNSManagedObject(savedItems[indexPath.row], context: managedContext!)
            savedItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func colorForDate(_ date: Date) -> UIColor {
        let todayDate = Date.init()
        let components = Calendar.current.dateComponents([.day], from: todayDate, to: date)
        
        var color: UIColor
        
        if components.day! < 3 {
            color = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.7)
        } else if components.day! < 7 {
            color = UIColor.init(red: 1, green: 1, blue: 0, alpha: 0.7)
        } else {
            color = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.7)
        }
        return color
    }
    
    func colorForPriority(_ priority: Priority) -> UIColor {
        var color: UIColor
        if (priority.value() == 2) {
            color = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.7)
        } else if (priority.value() == 1) {
            color = UIColor.init(red: 1, green: 1, blue: 0, alpha: 0.7)
        } else {
            color = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.7)
        }
        return color
    }
    
    // Segue Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        
        case "AddItem":
            print("adding item")
            
        case "ShowDetail":
            guard let itemDetailViewController = segue.destination as? ItemViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedItemCell = sender as? TODOItemViewCell else {
                fatalError("Unexpected sender: \(sender!)")
            }
            
            guard let indexPath = todoTable.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            if let selectedItem = itemFromNSManagedObject(savedItems[indexPath.row]) {
                itemDetailViewController.item = selectedItem
                itemDetailViewController.title = selectedItem.itemName
            }
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ItemViewController, let item = sourceViewController.item {
            if let selectedIndexPath = todoTable.indexPathForSelectedRow {
                updateItem(atRow: selectedIndexPath.row, item: item)
                todoTable.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                let newIndexPath = IndexPath(row: savedItems.count, section: 0)
                saveItem(item: item)
                
                todoTable.insertRows(at: [newIndexPath], with: .none)
            }
        }
    }
    
    // Core data functions
    
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
    
    func saveItem(item: TODOListItem) {
        let entity = NSEntityDescription.entity(forEntityName: "TODO_Item", in: managedContext!)!
        
        let savedItem = NSManagedObject(entity: entity, insertInto: managedContext)
        
        savedItem.setValue(item.itemName, forKeyPath: "name")
        savedItem.setValue(item.date, forKey: "date")
        savedItem.setValue(item.priority.value(), forKey: "priority")
        savedItem.setValue(item.itemDescription, forKey: "itemDescription")
        
        do {
            savedItems.append(savedItem)
            try managedContext!.save()
            print("saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateItem(atRow row: Int, item: TODOListItem) {
        
        let savedItem = savedItems[row]
        
        savedItem.setValue(item.itemName, forKeyPath: "name")
        savedItem.setValue(item.date, forKey: "date")
        savedItem.setValue(item.priority.value(), forKey: "priority")
        savedItem.setValue(item.itemDescription, forKey: "itemDescription")
        
        do {
            try managedContext!.save()
            print("saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteNSManagedObject(_ nsObject: NSManagedObject, context: NSManagedObjectContext) {
        context.delete(nsObject)
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
