//
//  NewConversationViewController.swift
//  MessangerApp
//
//  Created by administrator on 02/11/2021.
//

import UIKit

class NewConversationViewController: UIViewController, UISearchBarDelegate {

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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchBar.delegate = self
        self.navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                             target: self, action: #selector(dismissself))
        //to make the keyboard pop up first to the search bar
        searchBar.becomeFirstResponder()
    }
    
    @objc func dismissself(){
        self.dismiss(animated: true, completion: nil)
    }
    

}
