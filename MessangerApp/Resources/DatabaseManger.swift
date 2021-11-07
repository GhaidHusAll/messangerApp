//
//  DatabaseManger.swift
//  MessangerApp
//
//  Created by administrator on 01/11/2021.
//

import Foundation
import FirebaseDatabase
import Firebase
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
        self.database.child(user.safeEmail).setValue(["first_name":user.firstName,"last_name":user.lastName,"image_profile": user.imageProfile])
        DispatchQueue.main.async(){ self.insertUsers(username: "\(user.firstName)\( user.lastName)", email: user.safeEmail) { done in
            if done{
                completion(true) }else {
                    completion(false)
                }
        }
        }
        
    }
    //inser users to the app list of users
    public func insertUsers(username: String, email: String,completion: @escaping ((Bool) -> Void)){
        self.database.child("contect").observeSingleEvent(of: .value, with: {snapshot in
            if var users = snapshot.value as?[[String : String]]{
                // add to existing db child
                let newuser: [String:String] = [
                    
                    "name" : username ,
                    "email" : email
                ]
                
                users.append(newuser)
                self.database.child("contect").setValue(users, withCompletionBlock: {error,  _ in
                    guard  error != nil else {
                        completion(true)
                        return
                    }
                    completion(false)
                })
            }else{
                //create new collection for database if it does not exist
                let newUsers : [[String:String]]=[
                    [
                        "name" : username ,
                        "email" : email
                    ]
                ]
                self.database.child("contect").setValue(newUsers, withCompletionBlock: {error,  _ in
                    guard  error != nil else {
                        completion(true)
                        return
                    }
                    completion(false)
                })
            }
        } )
        
        
    }
    // fetch user's data
    public func getUser(email: String  ,completion: @escaping ((ChatAppUser) -> Void)) {
        var returnUser = ChatAppUser(firstName: "", lastName: "", emailAddress: "", imageProfile: "")
        let safeEmail = safeEmail(email: email)
        self.database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() { return }
            
            let firstname = snapshot.childSnapshot(forPath: "first_name").value
            let lastname = snapshot.childSnapshot(forPath: "last_name").value
            let urlimage = snapshot.childSnapshot(forPath: "image_profile").value
            returnUser  = ChatAppUser(firstName: firstname as! String, lastName: lastname as! String, emailAddress: email, imageProfile: urlimage as? String)
            DispatchQueue.main.async(){completion(returnUser)}
            
        })
    }
    //fetch users list of search
    public func getUsers( completion: @escaping (([[String:String]]) -> Void)) {
        var returnUsers = [[String:String]]()
        let ref = Database.database().reference(withPath: "contect")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() { return }
            for child in 0...snapshot.childrenCount - 1 {
                let name = snapshot.childSnapshot(forPath: "\(child)").childSnapshot(forPath: "name").value
                let email = snapshot.childSnapshot(forPath: "\(child)").childSnapshot(forPath: "email").value
                
                returnUsers.append(["name":  name as! String,
                                    "email" : email as! String,
                                    "profile_image": ""])
            }
            DispatchQueue.main.async(){completion(returnUsers)}
            
        })
    }
    //update user's image profile
    public func updateUserImage(image: String, email: String,completion: @escaping ((Bool) -> Void)) {
        let safeEmail = safeEmail(email: email)
        self.database.child(safeEmail).updateChildValues(["image_profile" : image])
        DispatchQueue.main.async(){
            completion(true)
            return
        }
        completion(false)
    }
    //function to get user Profile Image
    public func getUserImage(userEmail: String,completion: @escaping((String) -> Void)){
        let safeEmail = safeEmail(email: userEmail)
        var ImagePath = ""
        self.database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            
            if !snapshot.exists(){ImagePath = ""}else{
                ImagePath = snapshot.childSnapshot(forPath: "image_profile").value as! String
                DispatchQueue.main.async {completion(ImagePath)}
            }
        })
    }
    //-------------------------------conversation-----------------------------------
    // function to add conversatoin chat if it's exist add to it if does not exist creat in
    // database and add to it
    public func addConversation(message: message , senderId: String, receiverId: String ,completion: @escaping ((Bool) -> Void)){
        let safeEmail = safeEmail(email: senderId)
        
        let DateToString = String(Int64((message.date.timeIntervalSince1970  * 1000.0).rounded()))
        self.database.child(safeEmail).child("conversation").child(receiverId).observeSingleEvent(of: .value, with: {snapshot in
            if var Chats = snapshot.value as? [[String:String]]{
                // add to existing db child
                let newChat :[String : String] = [
                    
                    "date": DateToString,
                    "content" : "\(message.content)" ,
                    "isRead" : "\(message.isRead)",
                    "message_id": "\(message.id)",
                    "message_type": "\(message.type)"
                ]
                Chats.append(newChat)
                self.database.child(safeEmail).child("conversation").child(receiverId).setValue(Chats , withCompletionBlock: {error,  _ in
                    guard  error != nil else {
                        completion(true)
                        return
                    }
                    completion(false)
                })
            }else{
                //create new collection for database if it does not exist
                let newChat : [[String:String]] = [
                    [
                        "date": DateToString,
                        "content" : "\(message.content)" ,
                        "isRead" : "\(message.isRead)",
                        "message_id": "\(message.id)",
                        "message_type": "\(message.type)"
                    ]
                ]
                self.database.child(safeEmail).child("conversation").child(receiverId).setValue(newChat, withCompletionBlock: {error,  _ in
                    guard  error != nil else {
                        completion(true)
                        return
                    }
                    completion(false)
                })
            }
        } )
        
        
    }
    
    // function to fetch all contects belong to one user
    func fetchAllContectsUser(senderId: String,completion: @escaping (([String]) -> Void)){
        var returnUsers : [String] = []
        let safeEmail = safeEmail(email: senderId)
        self.database.child(safeEmail).child("conversation").observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { returnUsers = [] }
            for snap in snapshot.children {
                let Snap = snap as! DataSnapshot
                let userId = Snap.key
                returnUsers.append(userId)
            }
            self.database.observeSingleEvent(of: .value, with: { snapshot in
                if !snapshot.exists() { returnUsers = [] }
                
                for snap in snapshot.children {
                    let Snap = snap as! DataSnapshot
                    let userId = Snap.key
                    
                    if ((userId != "contect") && (userId != safeEmail) ) {
                        let allUsers = Snap.childSnapshot(forPath: "conversation")
                        print(allUsers.children)
                        for user in allUsers.children {
                            let Snap = user as! DataSnapshot
                            let conversationUserId = Snap.key
                            if conversationUserId == safeEmail {
                                returnUsers.append(userId)
                            }
                        }
                    }
                }
                DispatchQueue.main.async(){ let uniqueUsers = Array(Set(returnUsers))
                    completion(uniqueUsers)}
                
            })
        })
        
    }
    // function to fetch all chat/conversation between users
    func fetchAllChat(senderId: String,receiverId: String,completion: @escaping (([[String:Any]]) -> Void)){
        let safeEmail = safeEmail(email: senderId)
        var returnChats = [[String:Any]]()
       
        self.database.child(safeEmail).child("conversation").observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() {
                returnChats = []
                
            }else{
                
                for snap in snapshot.children {
                    let Snap = snap as! DataSnapshot
                    
                    if Snap.key == receiverId {
                        let messagesValue = Snap.value as! [[String:String]]
                        for singleMessage in messagesValue {
                            let date = Date(timeIntervalSince1970: TimeInterval(singleMessage["date"]!)! / 1000)
                            guard let isReadToBool = singleMessage["isRead"] else {print("from  is read ")
                                return}
                            var read = true
                            if isReadToBool == "false" {read = false}
                            returnChats.append(["content": (singleMessage["content"])!,
                                                     "date": date ,
                                                     "id": singleMessage["message_id"]!,
                                                     "isRead": read,
                                                     "type": singleMessage["message_type"]!,
                                                     "sender" : "me"
                            ])
                        } // messages for
                        
                    } // key if
                }// snap if
            } // else exist
            print("to reciver")
            self.database.child(receiverId).child("conversation").observeSingleEvent(of: .value, with: { snapshot in
                
                print("snap exist \(snapshot.exists())")
                if !snapshot.exists() {
                    DispatchQueue.main.async(){
                        print("from db \(returnChats)")
                        completion(returnChats)}
                    
                }else{
                    print("else")
                    for snap in snapshot.children {
                        let Snap = snap as! DataSnapshot
                        print("snapshot \(Snap)")
                        if Snap.key == safeEmail {
                            let messagesValue = Snap.value as! [[String:String]]
                            for singleMessage in messagesValue {
                                let date = Date(timeIntervalSince1970: TimeInterval(singleMessage["date"]!)! / 1000)
                                guard let isReadToBool = singleMessage["isRead"] else {return}
                                var read = true
                                if isReadToBool == "false" {read = false}
                                returnChats.append([
                                                    "content": (singleMessage["content"])!,
                                                          "date":date,
                                                          "id": singleMessage["message_id"]!,
                                                          "isRead": read,
                                                          "type": singleMessage["message_type"]!,
                                                   "sender" : "user"]
                                                   )
                            } // message for
                        } // key if
                    }// snap if
                } // else exist
                DispatchQueue.main.async(){
                    print("from db \(returnChats)")
                    completion(returnChats)}
                
            })
        })
    }
    //functon to upload message photos
    func uploudMessagePhoto(messageId: String,data: Data, completion: @escaping((Result<String, Error>) -> (Void))){
        let storageRef = Storage.storage().reference().child("messageImages/\(messageId)Image.png")
        storageRef.putData(data, metadata: nil, completion: {(matedata , putError) in
            guard putError == nil else {
                completion(.failure(putError!))
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
               guard  error == nil else {
                completion(.failure(StorageVoidURLError.self as! Error))
                return
               }
                DispatchQueue.main.async(){completion(.success(url!.absoluteString))}
            })
        })
    }
}
struct message {
    let content : String
    let date : Date
    let id : String
    let isRead : Bool // optionl
    let type : String
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
