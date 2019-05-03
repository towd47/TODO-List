//
//  ViewController.swift
//  TODO List
//
//  Created by Tom on 5/1/19.
//  Copyright © 2019 Towd47. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import UserNotifications

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var todoTable: UITableView!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var reminderSegue: UIButton!
    
    var itemDataHandler: CoreDataHandler?
    var sortedBy: String = "Priority"
    var itemToMakeReminderFor: TODOListItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "TODO List"
        
        itemDataHandler = CoreDataHandler.init()
        sort()
        
        todoTable.rowHeight = 90
        todoTable.delegate = self
        
        reminderSegue.isHidden = true
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(openRefresh), name: Notification.Name("OpenedApp"), object: nil)
    }
    
    @objc func openRefresh() {
        sort()
    }
    
    // List Sorting
    
    @IBAction func sortButtonPressed(_ sender: Any) {
        if sortedBy == "Priority" {
            sortedBy = "Date"
        }
        else {
            sortedBy = "Priority"
        }
        sortButton.title = "Sorted by: \(sortedBy)"
        sort()
    }
    
    func sort() {
        itemDataHandler?.sort(sortedBy: sortedBy)
        todoTable.reloadData()
    }
    
    // Table functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDataHandler!.savedItems.count
    }
    
    // Cell data population
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let item = itemDataHandler?.itemFromNSManagedObject(row: indexPath.row) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TODOItemViewCell", for: indexPath) as? TODOItemViewCell else {
                fatalError("Cell is not TODOItemViewCell")
            }
            
            cell.itemNameLabel.text = item.itemName
            
            let priorityName = item.priority.name()
            cell.spacerLabel.text = priorityName.first?.uppercased()
            cell.spacerLabel.backgroundColor = colorForPriority(item.priority)
            cell.spacerLabel.layer.borderColor = UIColor.darkGray.cgColor
            cell.spacerLabel.layer.borderWidth = 1
            
            cell.dateLabel.text = DateAndTimeDateFormatter.formateDateWithoutTime(item.date)
            cell.dateLabel.backgroundColor = colorForDate(item.date, isCompleted: item.priority == Priority.completed)
            cell.dateLabel.layer.borderColor = UIColor.darkGray.cgColor
            cell.dateLabel.layer.borderWidth = 1
                        
            return cell
        }
        fatalError("failed getting item from managedObject")
    }
    
    // row deletion handling
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = itemDataHandler?.itemFromNSManagedObject(row: indexPath.row)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item!.itemName])
            itemDataHandler!.deleteNSManagedObject(atRow: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        tableView.isEditing = false;
    }
    
    // swipe right on cell options
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let item = itemDataHandler!.itemFromNSManagedObject(row: indexPath.row)
        if item?.priority != Priority.completed {
            
            let addToCalAction = UIContextualAction(style: .normal, title: "Add to Calendar", handler: { (action, view, success) in
                success(true)
                self.addToCalButtonPressed(item: item!)
            })
            addToCalAction.backgroundColor = .purple
            
            let setReminderAction = UIContextualAction(style: .normal, title: "Create Reminder", handler: { (action, view, success) in
                success(true)
                self.createReminderButtonPressed(item: item!)
            })
            setReminderAction.backgroundColor = .blue
            
            let completeAction = UIContextualAction(style: .normal, title: "Mark Completed", handler: { (action, view, success) in
                success(true)
                let updatedItem = item!
                updatedItem.priority = Priority.completed
                self.itemDataHandler!.saveItem(atRow: indexPath.row, item: updatedItem)
                self.sort()
            })
            completeAction.backgroundColor = .magenta
            
            let actionsConfiguration = UISwipeActionsConfiguration(actions: [completeAction, addToCalAction, setReminderAction])
            actionsConfiguration.performsFirstActionWithFullSwipe = false
            
            return actionsConfiguration
        }
        else {
            let markIncompleteAction = UIContextualAction(style: .normal, title: "Mark Incomplete", handler: { (action, view, success) in
                success(true)
                let updatedItem = self.itemDataHandler!.itemFromNSManagedObject(row: indexPath.row)!
                updatedItem.priority = Priority.medium
                self.itemDataHandler!.saveItem(atRow: indexPath.row, item: updatedItem)
                self.sort()
            })
            markIncompleteAction.backgroundColor = .magenta
            
            return UISwipeActionsConfiguration(actions: [markIncompleteAction])
        }
    }
    
    
    // Reminder setup and creation
    
    func createReminderButtonPressed(item: TODOListItem) {
        itemToMakeReminderFor = item
        performSegue(withIdentifier: "CreateReminder", sender: nil)
    }
    
    func displayCreatedReminderConfimation() {
        let alert = UIAlertController(title: "Created Reminder for: \(String(describing: itemToMakeReminderFor!.itemName))", message: "", preferredStyle: .alert)
        
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                alert.dismiss(animated: true, completion: nil)
            }
        }        
    }
    
    func displayCreatedReminderConfimationFailure() {
        let alert = UIAlertController(title: "Reminder Failed", message: "Make sure the reminder is set to a time in the future.", preferredStyle: .alert)
        
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // Add to calendar
    func addToCalButtonPressed(item: TODOListItem) {
        let optionMenu = UIAlertController(title: "Add \(item.itemName) to calendar?", message: "\(item.itemName) will be added as an event at \(DateAndTimeDateFormatter.formateDateWithTime(item.date))?", preferredStyle: .actionSheet)
        
        let addToCalAction = UIAlertAction(title: "Yes", style: .default) {_ in
            self.addEventToCalendar(item: item)
            self.displayAddedConfimation()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(addToCalAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func addEventToCalendar(item: TODOListItem, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = item.itemName
                event.startDate = item.date
                event.endDate = item.date.addingTimeInterval(3600)
                event.notes = item.itemDescription
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
    }
    
    func displayAddedConfimation() {
        let alert = UIAlertController(title: "Added to Calendar", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    // Color functions for cell backgrounds
    
    func colorForDate(_ date: Date, isCompleted: Bool) -> UIColor {
        let todayDate = Date.init()
        let components = Calendar.current.dateComponents([.day], from: todayDate, to: date)
        
        var color: UIColor
        
        
        if isCompleted {
            color = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.5)
        } else if components.day! < 0 {
            color = UIColor.init(red: 1, green: 0, blue: 0, alpha: 1)
        } else if components.day! < 3 {
            color = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.5)
        } else if components.day! < 7 {
            color = UIColor.init(red: 1, green: 1, blue: 0, alpha: 0.45)
        } else {
            color = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.4)
        }
        return color
    }
    
    func colorForPriority(_ priority: Priority) -> UIColor {
        var color: UIColor
        if (priority.value() == 2) {
            color = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.5)
        } else if (priority.value() == 1) {
            color = UIColor.init(red: 1, green: 1, blue: 0, alpha: 0.45)
        } else if (priority.value() == 0){
            color = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.4)
        } else {
            color = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.5)
        }
        return color
    }
    
    // Segue Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        
        case "AddItem":
            print("Adding item")
            
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
            
            if let selectedItem = itemDataHandler!.itemFromNSManagedObject(row: indexPath.row) {
                itemDetailViewController.item = selectedItem
                itemDetailViewController.title = selectedItem.itemName
                
            }
            
        case "CreateReminder":
            guard let reminderViewController = segue.destination as? ReminderViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            reminderViewController.item = self.itemToMakeReminderFor
            
            
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ItemViewController, let item = sourceViewController.item {
            if let selectedIndexPath = todoTable.indexPathForSelectedRow {
                itemDataHandler!.saveItem(atRow: selectedIndexPath.row, item: item)
                todoTable.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                let newIndexPath = IndexPath(row: itemDataHandler!.savedItems.count, section: 0)
                itemDataHandler!.saveItem(atRow: -1, item: item)
                
                todoTable.insertRows(at: [newIndexPath], with: .none)
            }
            sort()
        }
        else if let sourceViewController = sender.source as? ReminderViewController, let succeded = sourceViewController.success, let notificationTimeIsInPast = sourceViewController.selectedNotificationTimeIsInThePast {
            print(succeded)
            if succeded {
                displayCreatedReminderConfimation()
            }
            else if notificationTimeIsInPast {
                displayCreatedReminderConfimationFailure()
            }
        }
    }
    
    // Refresh method
    
    func refresh() {
        todoTable.reloadData()
    }
}
