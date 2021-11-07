//
//  ChatViewController.swift
//  MessangerApp
//
//  Created by administrator on 02/11/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import JGProgressHUD
import IQKeyboardManagerSwift
// message model
struct Message: MessageType {
    
    public var sender: SenderType // sender for each message
    public var messageId: String // id to de duplicate
    public var sentDate: Date // date time
    public var kind: MessageKind // text, photo, video, location, emoji
}
extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
// sender model
struct Sender: SenderType {
    public var photoURL: String // extend with photo URL
    public var senderId: String
    public var displayName: String
    
}
class ChatViewController: MessagesViewController, UINavigationControllerDelegate {
    private let spinner = JGProgressHUD(style: .dark)
    private var messages = [Message]()
    var DB = DatabaseManger()
    var timerseconde = 10
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUser: Sender?
    public let User: Sender
    
    
    
    init(with user: Sender, otherUser: Sender?) {
        self.User = user
        self.otherUser = otherUser
        super.init(nibName: nil, bundle: nil)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init    (coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messages.removeAll()
        ImageBarItemButton()
        DispatchQueue.main.async {
            self.spinner.show(in: self.view)
            self.getChatContent()
        }
        // a timer start
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerRefrashr), userInfo: nil, repeats: true)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    func getChatContent(){
        guard let receiverId = otherUser?.senderId else {return}
        
        DB.fetchAllChat(senderId: User.senderId, receiverId: receiverId, completion: {theFetchedMessages in
            print("chat class \(theFetchedMessages[0]) and ")
            if !theFetchedMessages.isEmpty{
                let sortedChatsByTime = theFetchedMessages.sorted{ ((($0 as Dictionary<String, AnyObject>)["date"] as? Date)!) < (($1 as Dictionary<String, AnyObject>)["date"] as? Date)! }
                for oneMessage in sortedChatsByTime {
                    guard let guardOtherUser = self.otherUser else {return}
                    if (oneMessage["sender"] as! String) == "me" {
                    self.messages.append(Message(sender: self.User,
                                                 messageId: oneMessage["id"] as! String,
                                                 sentDate: oneMessage["date"] as! Date,
                                                 kind: .text(oneMessage["content"] as! String)))
                    } else {
                        self.messages.append(Message(sender: guardOtherUser ,
                                                     messageId: oneMessage["id"] as! String,
                                                     sentDate: oneMessage["date"] as! Date,
                                                     kind: .text(oneMessage["content"] as! String)))
                    }
                }
               
            }else{print("emmmptyy")}
            self.spinner.dismiss()
            self.messagesCollectionView.reloadData()
            
        })
    }
    // to keep the chat refresh every period of time
       @objc func updateTimerRefrashr(){
           if timerseconde > 0 {
                  timerseconde -= 1
           }else if (timerseconde == 0){
            viewDidLoad()
            timerseconde = 10
           }
           
       }
    //-----------imageINput ------------
    func ImageBarItemButton(){
        let imageButton = InputBarButtonItem()
        imageButton.setImage(UIImage(systemName: "paperclip.circle"), for: .normal)
        imageButton.setSize(CGSize(width: 40, height: 40), animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setStackViewItems([imageButton], forStack: .left, animated: false)
        imageButton.onTouchUpInside({ [weak self] _ in
            
        })
        
        
    }
}
//-------------------------------imagePickerExtension---------------
extension ChatViewController :UIImagePickerControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "send Media", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
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
        
//        self.profileImage.image = selectedImage
//        self.settheImage{ image in
//            self.spinner.show(in: self.view)
//            if let guardemail = self.email {
//                self.DB.updateUserImage(image: image, email: guardemail){ isDone in
//                    if isDone {
//                        return
//                    }else {
//                        self.alert(message: "Error occur updating Profile Image")
//                    }
//                }
//                self.spinner.dismiss()
//            }
//            
//        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

//-------------------------------inputBarExtension-------------------
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // if user text empty
        if  text.replacingOccurrences(of: " ", with: " ").isEmpty {
            return
        }// if user text is not empty
        else {
            messages.append(Message(sender: User, messageId: "1", sentDate: Date(), kind: MessageKind.text(text)))
            messagesCollectionView.scrollToLastItem(animated: true)
            //spinner.show(in: inputBar.sendButton, animated: true)
            // inputBar.sendButton.addSubview(spinner)
            //spinner.layer.transform = CATransform3DScale(spinner.layer.transform, 1.0, 3.0, 1.0);
            // spinner.frame = inputBar.sendButton.bounds
            let messageid = UUID().uuidString
            guard let receiverId = otherUser?.senderId else {return}
            
            //let date = Date.addingTimeInterval(Date())
            DB.addConversation(message: message(content: text, date: Date() , id: messageid, isRead: false, type: "text"), senderId: User.senderId, receiverId: receiverId , completion: {isDone in
                if isDone {
                    //saved
                    print("save conv")
                    // self.spinner.dismiss()
                }else {
                    // notsaved
                    print("not saved")
                }
            })
            inputBar.inputTextView.text = ""
            messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()

            
        }
    }
}
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return User
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubbleOutline(UIColor.init(displayP3Red: 51/255, green: 0/255, blue: 25/255, alpha: 1))
        }
    // change the defult bubble color
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
            return isFromCurrentSender(message: message) ? UIColor(red: 0, green: 0, blue: 0,  alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        }
    // set  time on each bubble message
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        let time = dateFormatter.string(from:  messages[indexPath.section].sentDate)
        return NSAttributedString(
          string: time,
          attributes: [
            .font: UIFont.preferredFont(forTextStyle: .caption1),
            .foregroundColor: UIColor(white: 0.3, alpha: 1)

          ]
        )
      }
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
          string: name,
          attributes: [
            .font: UIFont.preferredFont(forTextStyle: .caption1),
            .foregroundColor: UIColor(white: 0.3, alpha: 1)
          ])
    }
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 25
    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}
