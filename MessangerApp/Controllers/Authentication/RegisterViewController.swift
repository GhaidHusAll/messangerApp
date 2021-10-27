//
//  RegisterViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setbackground()
    }
    
    @IBAction func ToLogin(_ sender: Any) {
       if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
    }
    
    func setbackground () {
                //background
                let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
                backgroundImage.image = UIImage(named: "chatt.png")
                backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
                self.view.insertSubview(backgroundImage, at: 0)
        
    }
}
