//
//  ConversationViewController ConversationViewController.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

class ConversationViewController: UIViewController {
    
    
    private let spinner = JGProgressHUD(style: .light)
    
    
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var contactsTable: UITableView!
    @IBOutlet weak var usernamelbl: UILabel!
    @IBOutlet weak var userProfile: UIImageView!
    var email = UserDefaults.standard.string(forKey: "Email")
    var image = ""
    var name = ""
    var userInfo : [ChatAppUser] = []
    var contacts: [[String:String]] = []
    let DB = DatabaseManger()
    override func viewDidLoad() {
        super.viewDidLoad()
        setbackground()
        self.contactsTable.delegate = self
        self.contactsTable.dataSource = self
        
        
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
        NavBarSet()
        DispatchQueue.main.async(){
            self.spinner.show(in: self.view)
            self.spinner.textLabel.text = "Loading"
            self.setUser()
            self.getContacts()
        }
    }
    
    func setUser() {
        guard let guardemail = email else {return}
        DB.getUser(email: guardemail){ user in
            if !user.imageProfile!.isEmpty {
                self.image = user.imageProfile!
                if  let url = URL(string: user.imageProfile! ) {
                    DispatchQueue.main.async(){
                        self.userProfile.sd_setImage(with: url, completed: nil)
                        self.spinner.dismiss()
                    }
                }
            }else{
                self.spinner.dismiss()
                
            }
            let username = "\(user.firstName) \(user.lastName)"
            self.name = username
            self.usernamelbl.text = " HI \(username)   "
            self.userInfo.append(user)
        }
    }
    @objc func tapDetected() {
        let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "profile") as? ProfileViewController
        mainvc?.userinfo = self.userInfo
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(mainvc!, animated: true)
        
    }
    
    
    func NavBarSet(){
        self.title = "Conversation"
        // by making it large it will go down then the buttons
        self.navigationController?.navigationBar.prefersLargeTitles = true
        infoStackView.isHidden = false
        let barItem = UIBarButtonItem.init(customView: infoStackView)
        self.navigationItem.leftBarButtonItems = [barItem]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapComposeButton))
        
        
    }
    
    func setbackground () {
        // set background image
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = CGFloat(0.4);
        self.view.backgroundColor  = UIColor(patternImage: UIImage(named: "chatt.png")!)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurEffectView, at: 0)
    }
    
    
    @objc private func didTapComposeButton(){
        let newConversationVC = NewConversationViewController()
        newConversationVC.userSelectedDelegate = self
        let navVC = UINavigationController(rootViewController: newConversationVC)
        present(navVC,animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //tableView.frame = view.bounds
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
    
    func getContacts(){
        self.spinner.show(in: contactsTable)
        self.spinner.textLabel.text = "Loading Contacts..."
        DB.fetchAllContectsUser(senderId: email!, completion: { isFetch in
            if isFetch.isEmpty {
                //no contacts
            } else {
                let UserContacts = isFetch
                self.contacts = []
                var filters : [[String: String]] = [[:]]
                self.DB.getUsers(completion: { Users in
                    for count in UserContacts{
                        filters = Users.filter
                        { $0["email"]!.contains(count) }
                        self.contacts.append(filters[0])
                    }
                    self.spinner.dismiss()
                    self.contactsTable.reloadData()
                })
                
            }
        })
    }
    
}
extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactsTableViewCell
        
        cell.setUserCell(userNmae: contacts[indexPath.row]["name"]!, userId: contacts[indexPath.row]["email"]!,completion: { url in
            self.contacts[indexPath.row]["profile_image"] = url

        })
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // when user taps on a cell, we want to push the chat screen onto the stack
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        toChatViewController(index: indexPath.row)
        
    }
    func toChatViewController(index: Int){
       guard let otherName = contacts[index]["name"],
        let otherEmail = contacts[index]["email"],
        let otherImage = contacts[index]["profile_image"] else {return}
        let chatvc = ChatViewController(with: Sender(photoURL: image,
                                                     senderId: email!,
                                                     displayName: name) ,
                                        otherUser: Sender(photoURL: otherImage,
                                                           senderId: otherEmail,
                                                           displayName: otherName))
        chatvc.title = otherName
        chatvc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(chatvc, animated: true)
    }
    
}

//protocol class extenstion
extension ConversationViewController: SelectedUser{
    func UserData(userData: [String : String]) {
        contacts.append(userData)
        contactsTable.reloadData()
        toChatViewController(index: contacts.count - 1)
    }
    
    
}




