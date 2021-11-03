//
//  ProfileViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fulNamelbl: UITextField!
    @IBOutlet weak var emaillbl: UITextField!
    var userinfo : [ChatAppUser] = []
    var email = UserDefaults.standard.string(forKey: "Email")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInformation()
    }
    
    func setInformation(){
        self.fulNamelbl.text = "\(userinfo[0].firstName)  \(userinfo[0].lastName)"
        self.emaillbl.text = email!
        if  let url = URL(string: userinfo[0].imageProfile!) {
            let data = try? Data(contentsOf: url as URL)
            DispatchQueue.main.async(){
                self.profileImage.image = UIImage(data: data!)
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)

    }
    func setbackground () {
                // set background image
        view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt.png")!)
    }
    @IBAction func logout(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            let defaults = UserDefaults.standard
            defaults.set("", forKey: "Email")
            if let navController = self.navigationController {
                    navController.popToRootViewController(animated: true)
                         }
        }
               catch {
               }
            }
    

}
