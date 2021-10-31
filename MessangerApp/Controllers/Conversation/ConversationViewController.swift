//
//  ConversationViewController ConversationViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("hiii")
        setbackground()
    }
    override func viewDidAppear(_ animated: Bool) {
               super.viewDidAppear(animated)
         
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


