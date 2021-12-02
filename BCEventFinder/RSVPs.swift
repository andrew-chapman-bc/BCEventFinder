//
//  RSVPs.swift
//  BCEventFinder
//
//  Created by Andrew Chapman on 12/1/21.
//

import Foundation
import Firebase

class RSVPs {
    var rsvpArray: [RSVP] = []

    var db: Firestore!

    init() {
        db = Firestore.firestore()
    }
    
    func loadData(event: Event, completed: @escaping () -> ()) {
        guard event.documentID != "" else {
            return
        }
        db.collection("events").document(event.documentID).collection("rsvps").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.rsvpArray = [] // clean out existing spotArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // You'll have to make sre you have a dictionary initializer in the singular class
                let rsvp = RSVP(dictionary: document.data())
                rsvp.documentID = document.documentID
                self.rsvpArray.append(rsvp)
            }
            completed()
        }
    }
}
