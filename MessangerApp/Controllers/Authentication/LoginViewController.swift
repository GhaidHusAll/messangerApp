//
//  ViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var passWord: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setbackground()
    }
    override func viewWillAppear(_ animated: Bool) {
        // to hide the navigationbar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    @IBAction func ToRegister(_ sender: Any) {
        let addvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "register") as? RegisterViewController
               self.navigationController?.pushViewController(addvc!, animated: true)
    }
    
    @IBAction func loginByFacebook(_ sender: Any) {
    }
    @IBAction func Login(_ sender: Any) {
    }
    func setbackground () {
                // set background image
        view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt2.png")!)
    }
   
    
}

