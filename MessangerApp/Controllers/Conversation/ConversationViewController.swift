//
//  ConversationViewController ConversationViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
import JGProgressHUD

class ConversationViewController: UIViewController {
   
    
    private let spinner = JGProgressHUD(style: .dark)

    
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var contactsTable: UITableView!
    @IBOutlet weak var usernamelbl: UILabel!
    @IBOutlet weak var userProfile: UIImageView!
    var email = UserDefaults.standard.string(forKey: "Email")
    var userInfo : [ChatAppUser] = []
    let DB = DatabaseManger()
    override func viewDidLoad() {
        super.viewDidLoad()
        setbackground()
        DispatchQueue.main.async(){  self.spinner.show(in: self.view)
            self.setUser() }
        self.contactsTable.delegate = self
        self.contactsTable.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
       
       
    }
    func setAvater(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected))
    singleTap.numberOfTapsRequired = 1
    userProfile.isUserInteractionEnabled = true
    userProfile.addGestureRecognizer(singleTap)
        userProfile.layer.cornerRadius =  userProfile.frame.size.height / 6
    userProfile.clipsToBounds = true
    userProfile.layer.borderWidth = 3.0
    userProfile.layer.borderColor = UIColor.black.cgColor
    }
    override func viewWillAppear(_ animated: Bool) {
        setAvater()
    }
    
    func setUser() {
        guard let guardemail = email else {return}
        DB.getUser(email: guardemail){ user in
        if  let url = URL(string: user.imageProfile! ) {
                    let data = try? Data(contentsOf: url as URL)
                    
                    DispatchQueue.main.async(){
                        self.userProfile.image = UIImage(data: data!)
                        self.spinner.dismiss()
                    }
                }
        let username = "\(user.firstName)  \(user.lastName)"
                self.usernamelbl.text = " HI \(username)"
                self.userInfo.append(user)
               
        }
    }
    @objc func tapDetected() {
        let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "profile") as? ProfileViewController
        mainvc?.userinfo = self.userInfo
               self.navigationController?.pushViewController(mainvc!, animated: true)
        
    }
    override func viewDidAppear(_ animated: Bool) {
               super.viewDidAppear(animated)
        self.navigationController?.additionalSafeAreaInsets.top = 25
        let barItem = UIBarButtonItem.init(customView: infoStackView)
        self.navigationItem.leftBarButtonItems = [barItem]
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
           }
           
    @IBAction func logout(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            if let navController = self.navigationController {navController.popViewController(animated: true)}
        }
        catch {}
        
    }
   
    
    func setbackground () {
                // set background image
        view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt.png")!)
    }

       
       @objc private func didTapComposeButton(){
           let vc = NewConversationViewController()
           let navVC = UINavigationController(rootViewController: vc)
           present(navVC,animated: true)
       }
       
       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
          // tableView.frame = view.bounds
       }
       
       private func validateAuth(){
           // current user is set automatically when you log a user in
           if FirebaseAuth.Auth.auth().currentUser == nil {
               // present login view controller
               let vc = LoginViewController()
               let nav = UINavigationController(rootViewController: vc)
               nav.modalPresentationStyle = .fullScreen
               present(nav, animated: false)
           }
       }
       
}
   extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
       
       
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
       }
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
           cell.textLabel?.text = "Hello World"
           cell.accessoryType = .disclosureIndicator
           return cell
       }
       
       // when user taps on a cell, we want to push the chat screen onto the stack
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
           
        let chatvc = ChatViewController(with: email! , id: "1111")
        chatvc.title = "Chat"
        chatvc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(chatvc, animated: true)
        
       }
   }




