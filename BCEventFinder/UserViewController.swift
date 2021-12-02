//
//  UserViewController.swift
//  BCEventFinder
//
//  Created by Andrew Chapman on 11/30/21.
//

import UIKit
import Firebase

class UserViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var classYearTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var submitBarButton: UIBarButtonItem!
    
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
        if rsvp.documentID == "" {
            deleteButton.isEnabled = false
            deleteButton.isHidden = true
        } else {
            if rsvp.reviewUserID == Auth.auth().currentUser?.uid {
                self.submitBarButton.title = "Update"
                
            } else {
                deleteButton.isHidden = true
                deleteButton.isEnabled = false
                nameTextField.isEnabled = false
                classYearTextField.isEnabled = false
                emailTextField.isEnabled = false
                phoneNumberTextField.isEnabled = false
                submitBarButton.isEnabled = false
                submitBarButton.tintColor = .clear
            }
        }
        
        
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
        rsvp.deleteData(event: event) { success in
            if success {
                self.leaveViewController()
            } else {
                print("Delete Unsuccessful")
            }
        }
    }
    
    @IBAction func submitBarButtonPressed(_ sender: UIBarButtonItem) {
        if nameTextField.text!.isEmpty || classYearTextField.text!.isEmpty  {
            self.oneButtonAlert(title: "Missing Fields", message: "Please enter name and class year to submit RSVP")
            return
        }
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
