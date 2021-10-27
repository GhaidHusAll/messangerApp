//
//  ViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setbackground()
    }

    @IBAction func ToRegister(_ sender: Any) {
        let addvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "register") as? RegisterViewController
               self.navigationController?.pushViewController(addvc!, animated: true)
        
        print("hereee")
        
    }
    
    func setbackground () {
                //background
                let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
                backgroundImage.image = UIImage(named: "chatt.png")
                backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
                self.view.insertSubview(backgroundImage, at: 0)
        
    }
}

