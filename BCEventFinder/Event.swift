//
//  Event.swift
//  BCEventFinder
//
//  Created by Andrew Chapman on 11/30/21.
//

import Foundation
import Firebase

class Event {
    var name: String
    var place: String
    var roomNumber: String
    var numberOfDesiredPeople: Int
    var date: String
    var numberOfSignedUpPeople: Int
    var description: String
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["name": name, "place":place, "roomNumber": roomNumber, "numberOfDesiredPeople":numberOfDesiredPeople, "date": date, "numberOfSignedUpPeople":numberOfSignedUpPeople, "description":description, "postingUserID":postingUserID]
    }
    
    init(name: String, place: String, roomNumber: String, numberOfDesiredPeople: Int, date: String, numberOfSignedUpPeople: Int, description: String, postingUserID: String, documentID: String) {
        self.name = name
        self.place = place
        self.roomNumber = roomNumber
        self.numberOfDesiredPeople = numberOfDesiredPeople
        self.date = date
        self.numberOfSignedUpPeople = numberOfSignedUpPeople
        self.description = description
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(name: "", place: "", roomNumber: "", numberOfDesiredPeople: 0, date: "", numberOfSignedUpPeople: 0, description: "", postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let place = dictionary["place"] as! String? ?? ""
        let roomNumber = dictionary["roomNumber"] as! String? ?? ""
        let numberOfDesiredPeople = dictionary["numberOfDesiredPeople"] as! Int? ?? 0
        let date = dictionary["date"] as! String? ?? ""
        let numberOfSignedUpPeople = dictionary["numberOfSignedUpPeople"] as! Int? ?? 0
        let description = dictionary["description"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(name: name, place: place, roomNumber: roomNumber, numberOfDesiredPeople: numberOfDesiredPeople, date: date, numberOfSignedUpPeople: numberOfSignedUpPeople, description: description, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("ERROR: Could not save data becase we don't have a valid postingUserID.")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we have saved a record, we'll have an ID, otherwise .addDocument will create one.
        if self.documentID == "" { // Create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will create a new ID for us
            ref = db.collection("events").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID)") // It worked
                completion(true)
            }

        } else {// else save to the existing documentID w/ .setData
            let ref = db.collection("events").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)") // It worked
                completion(true)
            }
        }
    }
}
