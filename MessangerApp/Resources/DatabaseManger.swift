//
//  DatabaseManger.swift
//  MessangerApp
//
//  Created by administrator on 01/11/2021.
//

import Foundation
import FirebaseDatabase

final class DatabaseManger {
    
    static let shared = DatabaseManger()
    
    // reference the database below
    
    private let database = Database.database().reference()
    
    // create a simple write function
    
    
    
    public func test() {
        
      //  database.child("foo").setValue(["something":true])
    }
}
extension DatabaseManger {
    
    // have a completion handler because the function to get data out of the database is asynchrounous so we need a completion block
    func safeEmail (email : String)-> String{
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
          
           let safeEmail = safeEmail(email: email)
           database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
               if snapshot.exists() {
                   completion(false)
                   return
               }else { completion(true) }
           }
       }
       
       /// Insert new user to database
       public func insertUser(with user: ChatAppUser ,completion: @escaping ((Bool) -> Void)) {
           let isDone = true
       
            self.database.child(user.safeEmail).setValue(["first_name":user.firstName,"last_name":user.lastName,"image_profile": user.imageProfile])
        DispatchQueue.main.async(){completion(isDone) }
       
       }
    public func getUser(email: String  ,completion: @escaping ((ChatAppUser) -> Void)) {
        var returnUser = ChatAppUser(firstName: "", lastName: "", emailAddress: "", imageProfile: "")
        let safeEmail = safeEmail(email: email)
            let ref = Database.database().reference(withPath: safeEmail)
            ref.observeSingleEvent(of: .value, with: { snapshot in

                if !snapshot.exists() { return }

                let firstname = snapshot.childSnapshot(forPath: "first_name").value
                let lastname = snapshot.childSnapshot(forPath: "last_name").value
                let urlimage = snapshot.childSnapshot(forPath: "image_profile").value
                returnUser  = ChatAppUser(firstName: firstname as! String, lastName: lastname as! String, emailAddress: email, imageProfile: urlimage as? String)
                DispatchQueue.main.async(){completion(returnUser)}
               
            })
    }
    
}
   struct ChatAppUser {
       let firstName: String
       let lastName: String
       let emailAddress: String
       let imageProfile: String?
       //let profilePictureUrl: String
       
       // create a computed property safe email
       
       var safeEmail: String {
           var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
           safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
           return safeEmail
       }
   }
