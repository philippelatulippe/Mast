//
//  DMMessageViewController.swift
//  mastodon
//
//  Created by Shihab Mehboob on 29/03/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

class DMMessageViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    var messages: [MessageType] = []
    var mainStatus: [Status] = []
    var allPrevious: [Status] = []
    var allReplies: [Status] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colours.white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.zero)
        
        messagesCollectionView.backgroundColor = Colours.white
        
        messageInputBar.backgroundColor = Colours.white
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = Colours.white
        messageInputBar.contentView.backgroundColor = Colours.white
        messageInputBar.inputTextView.backgroundColor = Colours.white
        messageInputBar.inputTextView.placeholderLabel.text = "Direct Message"
        messageInputBar.inputTextView.placeholderTextColor = Colours.grayDark.withAlphaComponent(0.3)
        messageInputBar.inputTextView.textColor = Colours.grayDark
        messageInputBar.inputTextView.layer.borderColor = Colours.grayDark.withAlphaComponent(0.3).cgColor
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.keyboardAppearance = Colours.keyCol
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 7, left: 16, bottom: 4, right: 16)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 5, left: 9, bottom: 5, right: 9)
        
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 42, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor.clear
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = UIImage(named: "direct")?.maskWithColor(color: Colours.gray)
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 0
        messageInputBar.sendButton.addTarget(self, action: #selector(self.didTouchSend), for: .touchUpInside)
        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "500"
                $0.contentHorizontalAlignment = .left
                $0.setTitleColor(Colours.gray, for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                $0.setSize(CGSize(width: 40, height: 35), animated: false)
                $0.addTarget(self, action: #selector(self.didTouchOther), for: .touchUpInside)
            }.onTextViewDidChange { (item, textView) in
                item.title = "\(500 - textView.text.count)"
                let isOverLimit = textView.text.count > 500
                item.messageInputBar?.shouldManageSendButtonEnabledState = !isOverLimit
                if isOverLimit {
                    item.messageInputBar?.sendButton.isEnabled = false
                }
                let color = isOverLimit ? Colours.red : Colours.gray
                item.setTitleColor(color, for: .normal)
        }
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    self.messageInputBar.sendButton.image = UIImage(named: "direct")?.maskWithColor(color: Colours.tabSelected)
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    self.messageInputBar.sendButton.image = UIImage(named: "direct")?.maskWithColor(color: Colours.gray)
                })
        }
        let bottomItems = [charCountButton]
        messageInputBar.setStackViewItems(bottomItems, forStack: .left, animated: false)
        
        if self.mainStatus.isEmpty {} else {
            let request = Statuses.context(id: self.mainStatus[0].reblog?.id ?? self.mainStatus[0].id)
            StoreStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    self.allPrevious = (stat.ancestors)
                    self.allReplies = (stat.descendants)
                    
                    DispatchQueue.main.async {
                        for z in self.allPrevious + self.mainStatus + self.allReplies {
                            var theType = "0"
                            if z.account.acct == StoreStruct.currentUser.acct {
                                theType = "1"
                            }
                            let sender = Sender(id: theType, displayName: "\(z.account.displayName)")
                            let x = MockMessage.init(text: z.content.stripHTML().replace("@\(StoreStruct.currentUser.acct) ", with: "").replace("@\(StoreStruct.currentUser.acct)\n", with: "").replace("@\(StoreStruct.currentUser.acct)", with: ""), sender: sender, messageId: z.id, date: Date())
                            self.messages.append(x)
                            
                            if z.mediaAttachments.isEmpty {} else {
                                let url = URL(string: z.mediaAttachments.first?.previewURL ?? "")
                                let imageData = try! Data(contentsOf: url!)
                                let image1 = UIImage(data: imageData)
                                let y = MockMessage.init(image: image1!, sender: sender, messageId: z.id, date: Date())
                                self.messages.append(y)
                            }
                            
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToBottom()
                        }
                    }
                }
            }
        }
    }
    
    @objc func didTouchSend(sender: UIButton) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            impact.impactOccurred()
        }
        
        let sender = Sender(id: "1", displayName: "\(StoreStruct.currentUser.acct)")
        let x = MockMessage.init(text: self.messageInputBar.inputTextView.text.replace("@\(StoreStruct.currentUser.acct) ", with: "").replace("@\(StoreStruct.currentUser.acct)\n", with: "").replace("@\(StoreStruct.currentUser.acct)", with: ""), sender: sender, messageId: "18982", date: Date())
        self.messages.append(x)
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom()
        self.messageInputBar.inputTextView.text = ""
        
        let request0 = Statuses.create(status: self.messageInputBar.inputTextView.text, replyToID: self.mainStatus[0].inReplyToID, mediaIDs: [], sensitive: self.mainStatus[0].sensitive, spoilerText: StoreStruct.spoilerText, scheduledAt: nil, poll: nil, visibility: .direct)
        DispatchQueue.global(qos: .userInitiated).async {
            StoreStruct.client.run(request0) { (statuses) in
                print(statuses)
            }
        }
    }
    
    @objc func didTouchOther(sender: UIButton) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            impact.impactOccurred()
        }
        
        let controller = ComposeViewController()
        StoreStruct.spoilerText = self.mainStatus[0].reblog?.spoilerText ?? self.mainStatus[0].spoilerText
        controller.inReply = [self.mainStatus[0]]
        controller.inReplyText = self.mainStatus[0].account.username
        controller.prevTextReply = self.mainStatus[0].content.stripHTML()
        print(self.mainStatus[0].account.username)
        self.present(controller, animated: true, completion: nil)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? Colours.tabSelected : Colours.gray
    }
    
    func currentSender() -> Sender {
        return Sender(id: "1", displayName: "\(StoreStruct.currentUser.displayName)")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
}

struct MockMessage: MessageType {
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var kind: MessageKind
    
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(custom: Any?, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .custom(custom), sender: sender, messageId: messageId, date: date)
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
}

struct ImageMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
}
