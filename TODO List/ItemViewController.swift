//
//  ItemViewController.swift
//  TODO List
//
//  Created by Tom on 5/2/19.
//  Copyright © 2019 Towd47. All rights reserved.
//

import UIKit

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
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(ItemViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        dateField.inputView = datePicker
        
        if let item = item {
            nameTextField.text = item.itemName
            dateField.text = formateDate(item.date)
            prioritySelector.selectedSegmentIndex = item.priority.value()
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
        
        let name = nameTextField.text ?? ""
        let itemDescription = descriptionTextView.text ?? ""
        let priority = prioritySelector.selectedSegmentIndex
        let date = datePicker?.date
        
        item = TODOListItem.init(itemName: name, itemDescription: itemDescription, priorityInt: priority, date: date!)
    }
    
    func formateDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
}
