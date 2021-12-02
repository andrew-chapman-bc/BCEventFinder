//
//  EventDetailViewController.swift
//  BCEventFinder
//
//  Created by Andrew Chapman on 11/30/21.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    print("Just created the date formatter")
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

class EventDetailViewController: UIViewController {
    @IBOutlet weak var eventTitleField: UITextField!
    @IBOutlet weak var roomNumberField: UITextField!
    @IBOutlet weak var desiredPeopleField: UITextField!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextField: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dormField: UITextField!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var rsvpButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let dorms = ["66","Chevy","Claver","Cushing","Duchene","Fenwick","Fitzpatrick", "Gabelli", "Gonzaga","Greycliff",
    "Hardey","Iggy","Keyes","Kostka","Loyola","Medeiros","Mods","90","2k","Roncalli","Ruby","Shaw","Stayer","2150","Vandy",
    "Voute","Walsh","Welch","Williams","Xavier"]
    let thePicker = UIPickerView()
    var userDorm = ""
        
    var event: Event!
    var rsvps: RSVPs!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if event == nil {
            event = Event()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        thePicker.delegate = self
        thePicker.dataSource = self
        
        dormField.inputView = thePicker
        
        rsvps = RSVPs()

        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rsvps.loadData(event: event) {
            self.tableView.reloadData()
        }
        if event.documentID == "" {
            rsvpButton.isEnabled = false
            rsvpButton.isHidden = true
        } else {
            if event.postingUserID == Auth.auth().currentUser?.uid {
                saveBarButton.title = "Update"
            } else {
                datePicker.isHidden = true
                datePicker.isEnabled = false
                eventTitleField.isEnabled = false
                roomNumberField.isEnabled = false
                eventDescriptionTextField.isEditable = false
                dormField.isEnabled = false
                desiredPeopleField.isEnabled = false
                saveBarButton.isEnabled = false
                saveBarButton.tintColor = .clear
            }
        }
        
    }
    
    func updateUserInterface() {
        eventTitleField.text = event.name
        dormField.text = event.place
        roomNumberField.text = event.roomNumber
        desiredPeopleField.text = "\(event.numberOfDesiredPeople)"
        eventDateLabel.text = event.date
        eventDescriptionTextField.text = event.description
    }
    
    func updateFromInterface() {
        event.name = eventTitleField.text!
        event.place = dormField.text!
        event.roomNumber = roomNumberField.text!
        let numPeople:Int? = Int(desiredPeopleField.text ?? "0")
        event.numberOfDesiredPeople = numPeople!
        event.date = eventDateLabel.text!
        event.description = eventDescriptionTextField.text!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateFromInterface()
        switch segue.identifier ?? "" {
        case "AddUser":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! UserViewController
            destination.event = event
        case "ShowUser":
            let destination = segue.destination as! UserViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.rsvp = rsvps.rsvpArray[selectedIndexPath.row]
            destination.event = event
        default:
            print("Couldn't find a case for segue identifier \(segue.identifier!). This should not have happened!")
        }
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        self.view.endEditing(true)
        eventDateLabel.text = dateFormatter.string(from: sender.date)
    }
    @IBAction func rsvpButtonPressed(_ sender: UIButton) {
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        if eventTitleField.text!.isEmpty || dormField.text!.isEmpty || desiredPeopleField.text!.isEmpty || eventDateLabel.text!.hasPrefix("MM") || eventDateLabel.text!.isEmpty || eventDescriptionTextField.text!.isEmpty {
            self.oneButtonAlert(title: "Missing Fields", message: "Please fill out all fields in form")
            return
        }
        updateFromInterface()
        event.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud.")
            }
        }
    }
    

}

extension EventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rsvps.rsvpArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RsvpCell", for: indexPath) as! EventRsvpTableViewCell
        cell.rsvp = rsvps.rsvpArray[indexPath.row]
        if cell.rsvp.reviewUserID == event.postingUserID {
            cell.backgroundColor = .green
            cell.userNameLabel.text! += " (host)"
        }
        return cell
    }
    
}

extension EventDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dorms.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dorms[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userDorm = dorms[row]
        dormField.text = dorms[row]
        print(userDorm)
    }
}
