//
//  ProfileViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
import GoogleSignIn
import JGProgressHUD
import FBSDKLoginKit
import SDWebImage

class ProfileViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .light)
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fulNamelbl: UITextField!
    @IBOutlet weak var emaillbl: UITextField!
    var userinfo : [ChatAppUser] = []
    let DB = DatabaseManger()
    var email = UserDefaults.standard.string(forKey: "Email")
    override func viewDidLoad() {
        super.viewDidLoad()
        setbackground()
        spinner.show(in: view)
        setInformation()
    }
 
    func setInformation(){
        self.fulNamelbl.text = "\(userinfo[0].firstName)  \(userinfo[0].lastName)"
        self.emaillbl.text = email!
        if !userinfo[0].imageProfile!.isEmpty {
            if  let url = URL(string: userinfo[0].imageProfile!) {
                DispatchQueue.main.async(){
                    self.profileImage.sd_setImage(with: url, completed: nil)
                    self.spinner.dismiss()
                }
            }
        }else{
            self.spinner.dismiss()
            return
        }
    }
    func setImageAvater(){
        
        profileImage.layer.cornerRadius =  profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 3.0
        profileImage.layer.borderColor = UIColor.black.cgColor
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected))
        singleTap.numberOfTapsRequired = 1
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(singleTap)
        
    }
    @objc func tapDetected() {
        presentPhotoActionSheet()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        setImageAvater()
    }
    
    func setbackground () {
        // set background image
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = CGFloat(0.2);
        self.view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt.png")!)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurEffectView, at: 0)
    }
    @IBAction func logout(_ sender: Any) {
        
        //google sign out from account
        GIDSignIn.sharedInstance().signOut()
        //Facebook signout from account
        LoginManager().logOut()
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
    
    func settheImage(completion: @escaping ((String) -> Void)) {
        var urlImage = ""
        if let image = profileImage.image?.jpegData(compressionQuality: 0.5) {
            let storageRef = Storage.storage().reference().child("\(email!)Image.png")
            storageRef.putData(image, metadata: nil, completion: {(matedata , error) in
                if error != nil {
                    print("errpr  \(String(describing: error?.localizedDescription))")
                    self.alert(message: "Profile Image could not be uploaded")
                }else {
                    storageRef.downloadURL(completion: { (url, error) in
                       guard  error == nil else {return}
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
extension ProfileViewController :UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        
        self.profileImage.image = selectedImage
        self.settheImage{ image in
            self.spinner.show(in: self.view)
            if let guardemail = self.email {
                self.DB.updateUserImage(image: image, email: guardemail){ isDone in
                    if isDone {
                        return
                    }else {
                        self.alert(message: "Error occur updating Profile Image")
                    }
                }
                self.spinner.dismiss()
            }
            
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
