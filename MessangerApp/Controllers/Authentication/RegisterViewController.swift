//
//  RegisterViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailAdrress: UITextField!
    @IBOutlet weak var passWord: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setbackground()
        setImageAvater()
        
    }
    
    @IBAction func newRegister(_ sender: Any) {
    }
    @IBAction func ToLogin(_ sender: Any) {
       if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
    }
    func setImageAvater(){
       
        userProfileImage.layer.cornerRadius =  userProfileImage.frame.width / 4
        userProfileImage.clipsToBounds = true
        userProfileImage.layer.borderWidth = 3.0
        userProfileImage.layer.borderColor = UIColor.black.cgColor
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected))
    singleTap.numberOfTapsRequired = 1
    userProfileImage.isUserInteractionEnabled = true
    userProfileImage.addGestureRecognizer(singleTap)
        
    }
    @objc func tapDetected() {
         print("Single Tap on imageview")
    presentPhotoActionSheet()
     }
    func setbackground () {
                //background
        view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt2.png")!)

        
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
