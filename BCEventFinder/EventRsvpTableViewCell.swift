//
//  EventRsvpTableViewCell.swift
//  BCEventFinder
//
//  Created by Andrew Chapman on 12/2/21.
//

import UIKit

class EventRsvpTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userClassLabel: UILabel!
    
    var rsvp: RSVP! {
        didSet {
            userNameLabel.text = rsvp.name
            userClassLabel.text = "Class of \(rsvp.classYear)"
        }
    }
    
}
