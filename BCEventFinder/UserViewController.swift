//
//  UserViewController.swift
//  BCEventFinder
//
//  Created by Andrew Chapman on 11/30/21.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var classYearTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    var rsvp: RSVP!
    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard event != nil else {
            print("ERROR: No event passed to UserViewController")
            return
        }
        if rsvp == nil {
            rsvp = RSVP()
        }
        updateUserInterface()

    }
    
    func updateUserInterface() {
        nameTextField.text = rsvp.name
        classYearTextField.text = rsvp.classYear
        emailTextField.text = rsvp.email
        phoneNumberTextField.text = rsvp.phoneNumber
    }
    
    func updateFromUserInterface() {
        rsvp.name = nameTextField.text!
        rsvp.classYear = classYearTextField.text!
        rsvp.email = emailTextField.text!
        rsvp.phoneNumber = phoneNumberTextField.text!
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
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func submitBarButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        rsvp.saveData(event: event) { success in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR: cannot unwind due to error")
            }
        }
    }
}
