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
class ChatViewController: MessagesViewController {
    private let spinner = JGProgressHUD(style: .dark)
    private var messages = [Message]()
    let currentUser = Sender(photoURL: "", senderId: "self", displayName: "Coding Dojo")
    var DB = DatabaseManger()
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUserEmail: String
    private let conversationId: String?
    public var isNewConversation = false
    
    
    
    init(with email: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
        // creating a new conversation, there is no identifier
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init    (coder:) has not been implemented")
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .green
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        messages.append(Message(sender: currentUser, messageId: "1", sentDate: Date().addingTimeInterval(-80000), kind: MessageKind.text("hiii")))
        
        messages.append(Message(sender: Sender(photoURL: "", senderId: "22", displayName: "esle"), messageId: "3", sentDate: Date().addingTimeInterval(-70000), kind: MessageKind.text("hellow")))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // messageInputBar.inputTextView.becomeFirstResponder()
        
       
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate {
   
    
}
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return currentUser
    }
    
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    
}
