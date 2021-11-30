//
//  EventDetailViewController.swift
//  BCEventFinder
//
//  Created by Andrew Chapman on 11/30/21.
//

import UIKit

class EventDetailViewController: UIViewController {
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextField: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var myThing: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
    }
    @IBAction func rsvpButtonPressed(_ sender: UIButton) {
    }
    

}
