//
//  ItemViewController.swift
//  TODO List
//
//  Created by Tom on 5/2/19.
//  Copyright © 2019 Towd47. All rights reserved.
//

import UIKit
import EventKit

class ItemViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var prioritySelector: UISegmentedControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private var datePicker: UIDatePicker?
    
    var item: TODOListItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .dateAndTime
        datePicker?.minuteInterval = 15
        datePicker?.addTarget(self, action: #selector(ItemViewController.dateChanged(datePicker:)), for: .valueChanged)
        datePicker?.setDate(Date(), animated: false)
        
        dateField.inputView = datePicker
        
        if let item = item {
            nameTextField.text = item.itemName
            dateField.text = formateDate(item.date)
            
            var priorityVal = item.priority.value()
            if priorityVal == -1 {
                priorityVal = 3
            }
            prioritySelector.selectedSegmentIndex = priorityVal
            
            descriptionTextView.text = item.itemDescription
            
            datePicker?.setDate(item.date, animated: false)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ItemViewController.viewTapped(gestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        
        nameTextField.delegate = self
        updateSaveButtonState()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        
        dateField.text = formateDate(datePicker.date)
    }
    
    private func updateSaveButtonState() {
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        updateItem()
    }
    
    func updateItem() {
        let name = nameTextField.text ?? ""
        let itemDescription = descriptionTextView.text ?? ""
        var priority = prioritySelector.selectedSegmentIndex
        if priority == 3 {
            priority = -1
        }
        let date = datePicker?.date
        
        item = TODOListItem.init(itemName: name, itemDescription: itemDescription, priorityInt: priority, date: date!)
    }
    
    func formateDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma - MMMM d, yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
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
