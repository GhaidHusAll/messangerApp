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
import SDWebImage

// message model
struct Message: MessageType {
    
    public var sender: SenderType // sender for each message
    public var messageId: String // id to de duplicate
    public var sentDate: Date // date time
    public var kind: MessageKind // text, photo, video, location, emoji
}
//media modle
struct media : MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
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
        chatListner(receverId: otherUser!.senderId, senderId: user.senderId)
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
        ImageBarItemButton()
        
        spinner.show(in: self.view)
        setChats()
  
        
    }
   
    func chatListner(receverId: String , senderId: String){
        guard let receiverId = otherUser?.senderId else {return}
        
        DB.updateChat(senderId: User.senderId, receiverId: receiverId, completion: {[weak self] theFetchedMessage in

            guard let strongSelf = self else {return}
            if !theFetchedMessage.isEmpty{
                    guard let guardOtherUser = strongSelf.otherUser else {return}
                    var kind : MessageKind?
                    guard let placeHolder = UIImage(named: "emptyImage") else {return}

                    if (theFetchedMessage["type"] as? String  == "photo") {
                        let url = URL(string: theFetchedMessage["type"] as! String)
                        kind = .photo(media(url: url,
                                            image: nil,
                                            placeholderImage: placeHolder,
                                            size: CGSize(width: 200, height: 200)))
                    }else {
                        kind = .text(theFetchedMessage["content"] as! String )
                    }
                    guard let messageKind = kind else {return}
                        strongSelf.messages.append(Message(sender: guardOtherUser ,
                                                           messageId: theFetchedMessage["id"] as! String ,
                                                           sentDate: theFetchedMessage["date"]  as! Date ,
                                                     kind: messageKind ))
                    
                
            }else{print("emmmptyy")}
            DispatchQueue.main.async {
                strongSelf.messagesCollectionView.reloadData()
            }
            
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()

    }
    func setChats(){
        messages.removeAll()
        DispatchQueue.main.async {
            self.getChatContent()
        }
    }
    func getChatContent(){
        guard let receiverId = otherUser?.senderId else {return}
        DB.fetchAllChat(senderId: User.senderId, receiverId: receiverId, completion: {theFetchedMessages in
            if !theFetchedMessages.isEmpty{
                let sortedChatsByTime = theFetchedMessages.sorted{ ((($0 as Dictionary<String, AnyObject>)["date"] as? Date)!) < (($1 as Dictionary<String, AnyObject>)["date"] as? Date)! }
                self.messages.removeAll()
                for oneMessage in sortedChatsByTime {
                    guard let guardOtherUser = self.otherUser else {return}
                    var kind : MessageKind?
                    guard let placeHolder = UIImage(named: "emptyImage") else {return}

                    if (oneMessage["type"] as! String) == "photo" {
                        let url = URL(string: oneMessage["content"] as! String)
                        kind = .photo(media(url: url,
                                            image: nil,
                                            placeholderImage: placeHolder,
                                            size: CGSize(width: 200, height: 200)))
                    }else {
                        kind = .text(oneMessage["content"] as! String)
                    }
                    guard let messageKind = kind else {return}
                    if (oneMessage["sender"] as! String) == "me" {
                    self.messages.append(Message(sender: self.User,
                                                 messageId: oneMessage["id"] as! String,
                                                 sentDate: oneMessage["date"] as! Date,
                                                 kind: messageKind))
                    } else {
                        self.messages.append(Message(sender: guardOtherUser ,
                                                     messageId: oneMessage["id"] as! String,
                                                     sentDate: oneMessage["date"] as! Date,
                                                     kind: messageKind ))
                    }
                }
               
            }else{print("emmmptyy")}
            self.spinner.dismiss()
            self.messagesCollectionView.reloadData()
            
        })
    }
      
    //-----------imageINput ------------
    func ImageBarItemButton(){
        let imageButton = InputBarButtonItem()
        imageButton.setImage(UIImage(systemName: "paperclip.circle"), for: .normal)
        imageButton.setSize(CGSize(width: 40, height: 40), animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setStackViewItems([imageButton], forStack: .left, animated: false)
        imageButton.onTouchUpInside({ [weak self] _ in
            self?.presentPhotoActionSheet()
        })
        
        
    }
}
//-------------------------------imagePickerExtension---------------
extension ChatViewController :UIImagePickerControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "send Media", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
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
        let messageId = generateMessageId()
        spinner.show(in: view)
     if let imageAsData = selectedImage.jpegData(compressionQuality: 0.5) {
        DB.uploudMessagePhoto(messageId: messageId, data: imageAsData, completion: {[weak self] result in
            guard let strongSelf = self else {return}
            switch result {
            case .success(let url):
                let imageUrl = URL(string: url)
                guard let placeHolder = UIImage(named: "emptyImage") else {return}
                let newMessage = Message(sender: strongSelf.User,
                                         messageId: messageId,
                                         sentDate: Date(),
                                         kind: MessageKind.photo(media(url: imageUrl,
                                                                       image: nil,
                                                                       placeholderImage: placeHolder,
                                                                       size: .zero)))
                
                strongSelf.messages.append(newMessage)
                guard let receiverId = strongSelf.otherUser?.senderId else {return}
                strongSelf.DB.addConversation(message: message(content: url, date: Date() , id: messageId, isRead: false, type: newMessage.kind.messageKindString ), senderId: strongSelf.User.senderId, receiverId: receiverId , completion: {isDone in
                    if isDone {
                        //saved
                        print("save conv")
                        // self.spinner.dismiss()
                    }else {
                        // notsaved
                        print("not saved")
                    }
                })
                strongSelf.messagesCollectionView.reloadData()
                strongSelf.messagesCollectionView.scrollToLastItem()
                break
            case .failure(let error):
                self?.alert(message: error.localizedDescription)
                break
            
            }
            strongSelf.spinner.dismiss()
        })
        
     }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func alert(message: String) {
        let alert = UIAlertController(title: "Some Error Accur", message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
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
            let messageid = generateMessageId()
            let newMessage = Message(sender: User, messageId: messageid, sentDate: Date(), kind: MessageKind.text(text))
            
            messages.append(newMessage)
            messagesCollectionView.scrollToLastItem(animated: true)
           
            guard let receiverId = otherUser?.senderId else {return}
            
            //let date = Date.addingTimeInterval(Date())
            DB.addConversation(message: message(content: text, date: Date() , id: messageid, isRead: false, type: newMessage.kind.messageKindString), senderId: User.senderId, receiverId: receiverId , completion: {isDone in
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
    // generate random and uniqe strings for message id
    func generateMessageId() -> String {UUID().uuidString}
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
    // to set the message photo kind
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let singleMessage = message as? Message else {return}
        switch singleMessage.kind {
        case .photo(let media):
            guard let url = media.url else {return}
            imageView.sd_setImage(with: url, completed: nil)
        default:
        break
        }
    }
    
}
