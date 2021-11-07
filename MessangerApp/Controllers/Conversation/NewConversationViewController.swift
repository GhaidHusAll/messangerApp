//
//  NewConversationViewController.swift
//  MessangerApp
//
//  Created by administrator on 02/11/2021.
//

import UIKit
import JGProgressHUD

protocol SelectedUser {
    func UserData(userData: [String:String])
}
class NewConversationViewController: UIViewController, UISearchBarDelegate , UITableViewDelegate , UITableViewDataSource{
    
    
    private let spinner = JGProgressHUD(style: .light)
    //create search bar
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search For Contects....."
        return searchBar
    }()
    // create table View for the search contects
    private let tableView: UITableView = {
        let contectTable = UITableView()
        contectTable.isHidden = true
        contectTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return contectTable
    }()
    var contactes = [[String:String]]()
    var contactesFiltered = [[String:String]]()
    let DB = DatabaseManger()
    var userSelectedDelegate: SelectedUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        spinner.show(in: view)
        tableView.delegate = self
        tableView.dataSource = self
        DB.getUsers{ users in
            DispatchQueue.main.async {
                self.contactes = users
                self.spinner.dismiss()
                print(self.contactes)
            }
        }
        
        
        view.backgroundColor = .white
        searchBar.delegate = self
        self.navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self, action: #selector(dismissself))
        //to make the keyboard pop up first to the search bar
        searchBar.becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: view.frame.minX,
                                 y: view.frame.minY,
                                 width: view.frame.width,
                                 height: view.frame.height)
    }
    func update(){
        if !contactesFiltered.isEmpty {
            tableView.isHidden = false
            tableView.reloadData()
        }else{
            tableView.isHidden = true
        }
        spinner.dismiss()
    }
    @objc func dismissself(){
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactesFiltered.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = contactesFiltered[indexPath.row]
        self.dismiss(animated: true, completion: {[weak self] in
            self?.userSelectedDelegate.UserData(userData: selectedUser)
            
        })
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        cell.textLabel?.text = contactesFiltered[indexPath.row]["name"]
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let userSearch = searchBar.text,
              !userSearch.replacingOccurrences(of: " ", with: " ").isEmpty else {
            return
        }
        contactesFiltered.removeAll()
        spinner.show(in: view)
        filterSearchText(text: userSearch)
    }
    
    func filterSearchText(text: String){
        if contactes.isEmpty {
            print("no data")
        }else {
            let filters : [[String: String]] = self.contactes.filter(
                {
                    guard let user = $0["name"]?.localizedLowercase  else {
                        return false
                    }
                    return user.hasPrefix(text.lowercased())
                })
            self.contactesFiltered = filters
        }
        update()
    }
    
}
