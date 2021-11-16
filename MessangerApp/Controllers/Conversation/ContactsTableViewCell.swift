//
//  ContactsTableViewCell.swift
//  MessangerApp
//
//  Created by administrator on 06/11/2021.
//

import UIKit
import SDWebImage

class ContactsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNamelbl: UILabel!
    
    func setImageAvater(){
        
        userImage.layer.cornerRadius =  userImage.frame.size.height / 2
        userImage.clipsToBounds = true
        userImage.layer.borderWidth = 3.0
        userImage.layer.borderColor = UIColor.black.cgColor
        
    }
    func setUserCell(userNmae: String, userId: String, completion: @escaping ((String) -> Void)) {
        setImageAvater()
        var returnUrlString = ""
        let DB = DatabaseManger()
        userNamelbl.text = "  \(userNmae)"
        DB.getUserImage(userEmail: userId, completion: { stringUrl in
            returnUrlString = stringUrl
            
            if  let url = URL(string: stringUrl) {
                self.userImage.sd_setImage(with: url, completed: nil)
            }
            DispatchQueue.main.async {completion( returnUrlString)}

        })
        }
    
}
