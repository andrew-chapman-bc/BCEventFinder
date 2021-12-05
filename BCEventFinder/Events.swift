//
//  Events.swift
//  BCEventFinder
//
//  Created by Andrew Chapman on 12/1/21.
//

import Foundation
import Firebase

class Events {
    var eventArray: [Event] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("events").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.eventArray = [] // clean out existing spotArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // You'll have to make sre you have a dictionary initializer in the singular class
                let event = Event(dictionary: document.data())
                event.documentID = document.documentID
                self.eventArray.append(event)
            }
            completed()
        }
    }
    
    func searchData(searchText: String, completed: @escaping(Bool) -> ()) {
            let revisedText = searchText
            let eventssRef = db.collection("events")
        eventssRef
                .getDocuments() { (querySnapshot, err) in
                    guard err == nil else {
                        print("Error getting documents for search: \(err!.localizedDescription)")
                        return completed(false)
                    }
                    self.eventArray = []
                    print("amount of docs returned in searchData \(querySnapshot?.count ?? 0)")
                    for document in querySnapshot!.documents {
                        let event = Event(dictionary: document.data())
                        print("THE EVENT LOOP WILL BE \(event)")
                        for field in document.data() {
                            if field.key == "name"  {
                                print(field.value)
                                let checkName = String(describing: field.value)
                                if checkName.contains(revisedText) {
                                    print("adding this document: \(field.key):\(field.value)")
                                    event.documentID = document.documentID
                                    self.eventArray.append(event)
                                }
                            }
                        }
                    }
                    completed(true)
                }
        }
}
