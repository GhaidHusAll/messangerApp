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
class LoginViewController: UIViewController  {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var emailErrorlbl: UILabel!
    @IBOutlet weak var passwordErrorlbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setbackground()
    }
   
    
    @IBAction func loginWithFacebook(_ sender: Any) {
    }
    @IBAction func loginWithGoogle(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

          if let error = error {
            print("error \(error)")
            return
          }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                  let authError = error as NSError
                  if  authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    // The user is a multi-factor user. Second factor challenge is required.
                    let resolver = authError
                      .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in resolver.hints {
                      displayNameString += tmpFactorInfo.displayName ?? ""
                      displayNameString += " "
                    }
                    self.showTextInputPrompt(
                      withMessage: "Select factor to sign in\n\(displayNameString)",
                      completionBlock: { userPressedOK, displayName in
                        var selectedHint: PhoneMultiFactorInfo?
                        for tmpFactorInfo in resolver.hints {
                          if displayName == tmpFactorInfo.displayName {
                            selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                          }
                        }
                        PhoneAuthProvider.provider()
                          .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                             multiFactorSession: resolver
                                               .session) { verificationID, error in
                            if error != nil {
                              print(
                                "Multi factor start sign in failed. Error: \(error.debugDescription)"
                              )
                            } else {
                              self.showTextInputPrompt(
                                withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                completionBlock: { userPressedOK, verificationCode in
                                  let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                    .credential(withVerificationID: verificationID!,
                                                verificationCode: verificationCode!)
                                  let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                    .assertion(with: credential!)
                                  resolver.resolveSignIn(with: assertion!) { authResult, error in
                                    if error != nil {
                                      print(
                                        "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                      )
                                    } else {
                                      self.navigationController?.popViewController(animated: true)
                                    }
                                  }
                                }
                              )
                            }
                          }
                      }
                    )
                  } else {
                    self.showMessagePrompt(error.localizedDescription)
                    return
                  }
                  // ...
                  return
                }
                // User is signed in
                // ...
            }
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
            passwordErrorlbl.isHidden = false
        }else {passwordErrorlbl.isHidden = true}
        
        if ((!emailAddress.text!.isEmpty  || emailAddress.text != "") && (passWord.text != "" || !passWord.text!.isEmpty)){
            FirebaseAuth.Auth.auth().signIn(withEmail: emailAddress.text!, password: passWord.text!, completion: { authResult, error in
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
    func setbackground () {
                // set background image
        view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt2.png")!)
    }
   
    func showTextInputPrompt(withMessage message: String,
                               completionBlock: @escaping ((Bool, String?) -> Void)) {
        _ = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        _ = UIAlertAction(title: "Cancel", style: .cancel) { _ in
          completionBlock(false, nil)
        }
        
    }
    func showMessagePrompt(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
      }
    
}
