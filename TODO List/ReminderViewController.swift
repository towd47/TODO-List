//
//  ReminderViewController.swift
//  TODO List
//
//  Created by Tom on 5/3/19.
//  Copyright © 2019 Towd47. All rights reserved.
//

import UIKit
import UserNotifications

class ReminderViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDateLabel: UILabel!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var setReminderButton: UIBarButtonItem!
    
    var success: Bool?
    var failed: Bool?
    private var datePicker: UIDatePicker?
    
    var item: TODOListItem?
    
    override func viewDidLoad() {
        
        success = true
        failed = false
        
        itemNameLabel.text = item?.itemName
        itemDateLabel.text = formateDate(item!.date)
        descriptionTextView.text = item?.itemDescription
        
        
        datePicker = UIDatePicker()
        datePicker?.setDate(Date.init(timeIntervalSinceNow: TimeInterval.init(exactly: 60)!), animated: false)
        datePicker?.datePickerMode = .dateAndTime
        datePicker?.minuteInterval = 1
        datePicker?.addTarget(self, action: #selector(ItemViewController.dateChanged(datePicker:)), for: .valueChanged)
        datePicker?.minimumDate = Date()
        
        dateField.text = formateDate(datePicker!.date)
        
        dateField.inputView = datePicker
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ItemViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didAllow, error in})
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        
        dateField.text = formateDate(datePicker.date)
    }
    
    func formateDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma - MMMM d, yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === setReminderButton else {
            return
        }
        
        createReminder()
    }
    
    func createReminder() {
        let content = UNMutableNotificationContent();
        content.title = item!.itemName
        content.subtitle = "Scheduled for: \(formateDate(item!.date))"
        content.body = ""
        content.badge = 1
        content.sound = UNNotificationSound.default
        
        let interval = datePicker?.date.timeIntervalSinceNow
        
        if (interval! > 0) {
        
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval!, repeats: false)
            
            let request = UNNotificationRequest(identifier: item!.itemName, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if error == nil {
                    print("Notification Scheduled")
                }
                else {
                    print(error!)
                }
            }
        }
        else {
            success = false
            failed = true
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        success = false
        let isPresentingInAddItemMode = presentingViewController is UINavigationController
        
        if isPresentingInAddItemMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The ItemViewController is not inside a navigation controller.")
        }
    }
}
