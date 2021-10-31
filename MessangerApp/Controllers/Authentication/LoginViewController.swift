//
//  ViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var emailErrorlbl: UILabel!
    @IBOutlet weak var passwordEroorlbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setbackground()
    }
   
    
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser != nil {
            // present login view controller
            let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "dashboard") as? ConversationViewController
                   self.navigationController?.pushViewController(mainvc!, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        // to hide the navigationbar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        validateAuth()
    }
    @IBAction func ToRegister(_ sender: Any) {
        let addvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "register") as? RegisterViewController
               self.navigationController?.pushViewController(addvc!, animated: true)
    }
    
    @IBAction func loginByFacebook(_ sender: Any) {
    }
    @IBAction func Login(_ sender: Any) {
        if (emailAddress.text == "" || emailAddress.text == nil )  {
            emailErrorlbl.text = "You need to fill Email"
            emailErrorlbl.isHidden = false
        } else {emailErrorlbl.isHidden = true}
        if (passWord.text == "" || passWord.text == nil || passWord.text!.count < 6){
            passwordEroorlbl.isHidden = false
        }else {passwordEroorlbl.isHidden = true}
        
        if ((!emailAddress.text!.isEmpty  || emailAddress.text != "") && (passWord.text != "" || !passWord.text!.isEmpty)){
            FirebaseAuth.Auth.auth().signIn(withEmail: emailAddress.text!, password: passWord.text!, completion: { authResult, error in
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(String(describing: self.emailAddress.text))")
                self.emailErrorlbl.isHidden = false
                self.emailErrorlbl.text = "Failed to log in"
                return
            }
            let user = result.user
                let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "dashboard") as? ConversationViewController
                       self.navigationController?.pushViewController(mainvc!, animated: true)
                print("logged in user: \(user)")
        })
        }
        }
    func setbackground () {
                // set background image
        view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt2.png")!)
    }
   
    
}

