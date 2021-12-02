//
//  RSVP.swift
//  BCEventFinder
//
//  Created by Andrew Chapman on 12/1/21.
//

import Foundation
import Firebase

class RSVP {
    var name: String
    var classYear: String
    var email: String
    var phoneNumber: String
    var reviewUserID: String
    var documentID: String

    var dictionary: [String: Any] {
        return ["name": name, "classYear": classYear, "email": email, "phoneNumber": phoneNumber, "reviewUserID": reviewUserID]
    }

    init(name: String, classYear: String, email: String, phoneNumber: String, reviewUserID: String, documentID: String) {
        self.name = name
        self.classYear = classYear
        self.email = email
        self.phoneNumber = phoneNumber
        self.reviewUserID = reviewUserID
        self.documentID = documentID
    }

    convenience init() {
        let reviewUserID = Auth.auth().currentUser?.uid ?? ""
        //let reviewUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(name: "", classYear: "", email: "", phoneNumber: "", reviewUserID: reviewUserID, documentID: "")
    }
    
    convenience init(dictionary: [String:Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let classYear = dictionary["classYear"] as! String? ?? ""
        let email = dictionary["email"] as! String? ?? ""
        let phoneNumber = dictionary["phoneNumber"] as! String? ?? ""
        let reviewUserID = dictionary["reviewUserID"] as! String? ?? ""
        let documentID = dictionary["documentID"] as! String? ?? ""

        self.init(name: name, classYear: classYear, email: email, phoneNumber: phoneNumber, reviewUserID: reviewUserID, documentID: documentID)
    }

    func saveData(event: Event, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        
        let dataToSave: [String: Any] = self.dictionary
        // if we have saved a record, we'll have an ID, otherwise .addDocument will create one.
        if self.documentID == "" { // Create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will create a new ID for us
            ref = db.collection("events").document(event.documentID).collection("rsvps").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID) to spot: \(event.documentID)") // It worked
                completion(true)
                
            }
        } else { // else save to the existing documentID w/ .setData
            let ref = db.collection("events").document(event.documentID).collection("rsvps").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID) in spot: \(event.documentID)") // It worked
                completion(true)
                
            }
        }
    }
    
    func deleteData(event:Event, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("events").document(event.documentID).collection("rsvps").document(documentID).delete { (error) in
            if let error = error {
                print("ERROR: deleting review documentID \(self.documentID). ERROR: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Successfully deleted document \(self.documentID)")
                completion(true)
                
            }
        }
    }
}
