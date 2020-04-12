//
//  Spot.swift
//  Snacktacular
//
//  Created by Yi Li on 4/11/20.
//  Copyright © 2020 John Gallaugher. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class Spot {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var longtitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var dictionary: [String: Any] {
        return["name": name, "address": address, "longtitude": longtitude, "latitude": latitude, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
    }
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        //Grab User ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Don't have valid user ID")
            return completed(false)
        }
        self.postingUserID = postingUserID
        //Creating the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        //if we have save a record, we have a documentID
        if self.documentID != "" {
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** ERROR: updating document \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil //Let firestone create new document ID
            ref = db.collection("spots").addDocument(data: dataToSave) { (error) in
                if let error = error {
                    print("*** ERROR: creating new document \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("New document created with ref ID \(ref?.documentID ?? "unknown")")
                    completed(true)
                }
            }
        }
    }
}

