//
//  ConversationViewController ConversationViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
class ConversationViewController: UIViewController {
    
    @IBOutlet weak var usernamelbl: UILabel!
    @IBOutlet weak var userProfile: UIImageView!
    var email = UserDefaults.standard.string(forKey: "Email")
    override func viewDidLoad() {
        super.viewDidLoad()
        setbackground()
       getUser()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected))
    singleTap.numberOfTapsRequired = 1
    userProfile.isUserInteractionEnabled = true
    userProfile.addGestureRecognizer(singleTap)
    }
    func getUser() {
        guard let guardemail = email else {return}
        var safeEmail = guardemail.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
                let ref = Database.database().reference(withPath: safeEmail)
            ref.observeSingleEvent(of: .value, with: { snapshot in

                if !snapshot.exists() { return }

                let firstname = snapshot.childSnapshot(forPath: "first_name").value
                let lastname = snapshot.childSnapshot(forPath: "last_name").value
                let urlimage = snapshot.childSnapshot(forPath: "image_profile").value
                if  let url = URL(string: urlimage! as! String ) {
                    let data = try? Data(contentsOf: url as URL)
                    
                    DispatchQueue.main.async(){
                        self.userProfile.image = UIImage(data: data!)
                    }
                }
                let username = "\(firstname!)  \(lastname!)"
                self.usernamelbl.text = " HI \(username)"

            })
        
    }
    @objc func tapDetected() {
        let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "profile") as? ProfileViewController
               self.navigationController?.pushViewController(mainvc!, animated: true)
        
    }
    override func viewDidAppear(_ animated: Bool) {
               super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
           }
           
    @IBAction func logout(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                         }
        }
               catch {
               }
        
    }
   
    
    func setbackground () {
                // set background image
        view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt.png")!)
    }
    
}


