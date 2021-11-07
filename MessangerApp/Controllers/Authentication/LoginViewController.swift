//
//  ViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import JGProgressHUD
import FBSDKLoginKit
class LoginViewController: UIViewController, GIDSignInUIDelegate , LoginButtonDelegate  {
    
    
    
    private let spinner = JGProgressHUD(style: .light)
    
    @IBOutlet weak var loginWithFaceBoolk: FBLoginButton!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var emailErrorlbl: UILabel!
    @IBOutlet weak var passwordErrorlbl: UILabel!
    var loginobserver : NSObjectProtocol?
    let DB = DatabaseManger()
    override func viewDidLoad() {
        super.viewDidLoad()
        loginWithFaceBoolk.permissions = ["public_profile", "email"]
        GIDSignIn.sharedInstance().uiDelegate = self
        self.loginWithFaceBoolk.delegate = self
        
        //                do {
        //                    try FirebaseAuth.Auth.auth().signOut()
        //                    let defaults = UserDefaults.standard
        //                    defaults.set("", forKey: "Email")
        //
        //                }
        //                catch {
        //                }
        //
        
        //to communecate between to parties the app and others
        loginobserver = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue:"LogInNotification"), object: nil, queue: .main, using:{ [weak self ]_ in
            guard let strongSelf = self else {return}
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            //reload and enter the app after google sign in
            self?.validateAuth()
            
        })
        setbackground()
        
    }
    // to remove and clear the notification when it's ends
    deinit {
        if let removeNotification = loginobserver {
            NotificationCenter.default.removeObserver(removeNotification)
            
        }
        print("after logg in")
    }
    
    @IBAction func loginWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    @IBAction func ToRegister(_ sender: Any) {
        let addvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "register") as? RegisterViewController
        self.navigationController?.pushViewController(addvc!, animated: true)
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            alert(message: "Failed To LogIn with FaceBook")
            return
        }
        print("logged in")
        let facebookData = FBSDKLoginKit.GraphRequest(graphPath: "/me", parameters: ["fields" : "email, name"], tokenString: token, version: nil, httpMethod: .get)
        facebookData.start(completion: {_,result,error in
            guard let result  = result as? [String:Any], error == nil else {
                self.alert(message: "Failed To LogIn with FaceBook")
                return
            }
            print("logged in")
            guard let userName = result["name"] as? String, let emailAddress = result["email"] as? String else {return}
            let userNameSaperated = userName.components(separatedBy: " ")
            guard userNameSaperated.count >= 2 else {return}
            let firstName = userNameSaperated[0]
            let lastName = userNameSaperated[1]
            
            self.DB.userExists(with: emailAddress){ notExist in
                if notExist {
                    self.DB.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: emailAddress, imageProfile: ""),
                                       completion: { isDone in
                                        if isDone {
                                            //seccuss
                                        }
                                       })
                }
                //exist in database
                let credentialFaceBook = FacebookAuthProvider.credential(withAccessToken: token)
                FirebaseAuth.Auth.auth().signIn(with: credentialFaceBook, completion: { [weak self] resultSignin , error in
                    guard let StrongSelf = self else {return}
                    guard resultSignin != nil , error == nil else {
                        //failed
                        return
                    }
                    // success
                    let defaults = UserDefaults.standard
                    defaults.set(emailAddress, forKey: "Email")
                    print(UserDefaults.standard.string(forKey: "Email")!)
                    let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "dashboard") as? ConversationViewController
                    StrongSelf.navigationController?.pushViewController(mainvc!, animated: true)
                })
            }
            
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //NAN
    }
    func alert(message: String) {
        let alert = UIAlertController(title: "Some Error occur", message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func Login(_ sender: Any) {
        if (emailAddress.text == "" || emailAddress.text == nil )  {
            emailErrorlbl.text = "You need to fill Email"
            emailErrorlbl.isHidden = false
        } else {emailErrorlbl.isHidden = true}
        if (passWord.text == "" || passWord.text == nil || passWord.text!.count < 6){
            passwordErrorlbl.isHidden = false
        }else {passwordErrorlbl.isHidden = true}
        
        if ((!self.emailAddress.text!.isEmpty  || self.emailAddress.text != "") && (self.passWord.text != "" || !self.passWord.text!.isEmpty)){
            FirebaseAuth.Auth.auth().signIn(withEmail: self.emailAddress.text!, password: self.passWord.text!, completion: { authResult, error in
                guard let result = authResult, error == nil else {
                    print("Failed to log in user with email \(String(describing: self.emailAddress.text))")
                    self.emailErrorlbl.isHidden = false
                    self.emailErrorlbl.text = "Failed to log in"
                    return
                }
                let user = result.user
                let defaults = UserDefaults.standard
                defaults.set(self.emailAddress.text, forKey: "Email")
                let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "dashboard") as? ConversationViewController
                self.navigationController?.pushViewController(mainvc!, animated: true)
                print("logged in user: \(user)")
            })
        }
    }
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser != nil {
            // present login view controller
            let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "dashboard") as? ConversationViewController
            self.navigationController?.pushViewController(mainvc!, animated: true)
        }
    }
    func viewDidReceiveNotification(notification: Notification) -> Void
    {
        if (notification.name.rawValue == "LogInNotification")
        {
            print("Notification Received")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        // to hide the navigationbar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        validateAuth()
    }
    func setbackground () {
        // set background image
        view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt2.png")!)
    }
    
    
    
}
