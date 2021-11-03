//
//  RegisterViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
import FirebaseStorage
class RegisterViewController: UIViewController {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailAdrress: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var informationErrorlbl: UILabel!
    @IBOutlet weak var passwordErrorlbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setbackground()
        setImageAvater()
        
    }
    
    @IBAction func newRegister(_ sender: Any) {
        
        if (emailAdrress.text!.isEmpty || lastName.text!.isEmpty || firstName.text!.isEmpty )  {
            informationErrorlbl.text = "You need to fill all the Fields"
            informationErrorlbl.isHidden = false
        } else {informationErrorlbl.isHidden = true}
        if (passWord.text == "" || passWord.text == nil || passWord.text!.count < 6){
            passwordErrorlbl.isHidden = false
        }else {passwordErrorlbl.isHidden = true}
        
        if ((!emailAdrress.text!.isEmpty  || emailAdrress.text != "") && (passWord.text != "" || !passWord.text!.isEmpty)){
            setUser()
            
        }
    }
    @IBAction func ToLogin(_ sender: Any) {
       if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
    }
    func setImageAvater(){
       
        userProfileImage.layer.cornerRadius =  userProfileImage.frame.size.height / 2
        userProfileImage.clipsToBounds = true
        userProfileImage.layer.borderWidth = 3.0
        userProfileImage.layer.borderColor = UIColor.black.cgColor
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected))
    singleTap.numberOfTapsRequired = 1
    userProfileImage.isUserInteractionEnabled = true
    userProfileImage.addGestureRecognizer(singleTap)
        
    }
    @objc func tapDetected() {
    presentPhotoActionSheet()
     }
    func setbackground () {
                //background
        view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt2.png")!)

        
    }
    func setUser(){
        let db = DatabaseManger()
        db.userExists(with: emailAdrress.text!){ isExist in
            if isExist {
                FirebaseAuth.Auth.auth().createUser(withEmail: self.emailAdrress.text! , password: self.passWord.text!, completion: { authResult , error  in
        guard let result = authResult, error == nil else {
            self.informationErrorlbl.text = "Some Error Accur Try Later "
            self.informationErrorlbl.isHidden = false
            print("Error creating user")
            return
        }
        let _ = result.user
       self.settheImage{ image in
            print(image)
         db.insertUser(with: ChatAppUser(firstName: self.firstName.text!, lastName: self.lastName.text!, emailAddress: self.emailAdrress.text!, imageProfile: image)) { issdone in
            if issdone {
                let defaults = UserDefaults.standard
            defaults.set(self.emailAdrress.text, forKey: "Email")
                self.navigationController?.popViewController(animated: true)
                   }
         }
       }
               })
        
                
            }else  { self.informationErrorlbl.text = "The email already exist"
                self.informationErrorlbl.isHidden = false
                return
            }
        }
        
    }
    func settheImage(completion: @escaping ((String) -> Void)) {
        print("innn")
        var urlImage = ""
        if let image = userProfileImage.image?.jpegData(compressionQuality: 0.5) {
            let storageRef = Storage.storage().reference().child("\(emailAdrress.text!)Image.png")
        storageRef.putData(image, metadata: nil, completion: {(matedata , error) in
            if error != nil {
                print("errpr  \(String(describing: error?.localizedDescription))")
                self.alert(message: "Profile Image could not be uploaded")
            }else {
                storageRef.downloadURL(completion: { (url, error) in
                    DispatchQueue.main.async(){ urlImage = url!.absoluteString
                        completion(urlImage)}
                        })
            }
        })
        }else {completion(urlImage)}
    }
    func alert(message: String) {
        let alert = UIAlertController(title: "Some Error Accur", message:message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
        
    }
}
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // take a photo or select a photo
        
        // action sheet - take photo or choose photo
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.userProfileImage.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
