//
//  UserChatViewController.swift
//  YahdehDemo
//
//  Created by iMac on 2/10/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Toast_Swift
import RealmSwift
import XMPPFramework
import NVActivityIndicatorView

class UserChatViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,XMPPStreamDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var user:User!
    var avatarImage:UIImageView!
    public var friendIsAdded = false
    let chatTableView = UITableView()
    let messageTextField = UITextField()
    var roomMessages:[RoomMessage]!
    let activity = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: .ballPulse, color: darkRedColor, padding: nil)
    let photoPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        avatarImage = UIImageView()
        self.view.addSubview(avatarImage)
        avatarImage.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(72)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        avatarImage.backgroundColor = UIColor.lightGray
        avatarImage.contentMode = .center
        avatarImage.layer.cornerRadius = 40
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.borderColor = UIColor.lightGray   .cgColor
        avatarImage.layer.borderWidth = 2
        avatarImage.kf.setImage(with: URL(string: "http://dev-api.yahdeh.com/\(user.avatar ?? "")"))
        
        let userNameLabel = UILabel()
        self.view.addSubview(userNameLabel)
        userNameLabel.text = user.username
        userNameLabel.textColor = UIColor.black
        userNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .black)
        userNameLabel.textAlignment = .center
        userNameLabel.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(30)
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(avatarImage.snp.bottom).offset(8)
        }
        
        let nameLabel = UILabel()
        self.view.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.textColor = UIColor.darkGray
        nameLabel.font = UIFont.systemFont(ofSize: 11, weight: .light)
        nameLabel.textAlignment = .center
        nameLabel.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(30)
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(userNameLabel.snp.bottom)
        }
        
        if friendIsAdded == false {
            let reqButton = UIButton(type: .roundedRect)
            reqButton.setTitle("Send Request", for: .normal)
            reqButton.setTitleColor(darkRedColor, for: .normal)
            reqButton.addTarget(self , action: #selector(self.sendRequestToUser), for: .touchUpInside)
            self.view.addSubview(reqButton)
            reqButton.snp.makeConstraints { (make) in
                make.width.equalTo(120)
                make.height.equalTo(35)
                make.centerX.equalTo(self.view.snp.centerX)
                make.top.equalTo(nameLabel.snp.bottom).offset(8)
            }
        }
            
        else {
            self.roomMessages = RoomMessage.getMessagesForUsers(id1: self.user.username, id2: UserAuth.getSavedObject()!.username)
            
            photoPicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            photoPicker.sourceType = .photoLibrary
            photoPicker.modalPresentationStyle = .overCurrentContext
            chatTableView.delegate = self
            chatTableView.dataSource = self
            chatTableView.dropShadow()
            chatTableView.separatorStyle = .none
            
            let toolBar = UIToolbar()
            
            messageTextField.borderStyle = .roundedRect
            
            let uploadButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.sendPhoto))
            uploadButton.tintColor = darkRedColor
            
            let sendButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(self.sendMessage))
            sendButton.tintColor = darkRedColor
            messageTextField.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width - 100, height: 40)
            let textFieldCustom = UIBarButtonItem(customView: messageTextField)
            toolBar.items = [uploadButton,textFieldCustom,sendButton]
            self.view.addSubview(toolBar)
            self.view.addSubview(chatTableView)
            
            toolBar.snp.makeConstraints { (make) in
                make.left.equalTo(self.view.snp.left)
                make.right.equalTo(self.view.snp.right)
                make.bottom.equalTo(self.view.snp.bottom).offset(-50)
                make.height.equalTo(50)
            }
            toolBar.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            chatTableView.snp.makeConstraints { (make) in
                make.left.equalTo(self.view.snp.left)
                make.right.equalTo(self.view.snp.right)
                make.bottom.equalTo(toolBar.snp.top)
                make.top.equalTo(nameLabel.snp.bottom).offset(8)
            }
            
            self.view.backgroundColor = UIColor.white
            self.chatTableView.scrollToBottom(animated: true)
            
            photoPicker.view.addSubview(activity)
            activity.snp.makeConstraints { (make) in
                make.width.equalTo(100)
                make.height.equalTo(100)
                make.center.equalTo(photoPicker.view.snp.center)
            }
            
            XMPPController.shared.xmppStream.addDelegate(self , delegateQueue: DispatchQueue.main)            
            XMPPController.shared.sendPresence(user: user.username+"@yahdeh")
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        XMPPController.shared.xmppStream.removeDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func sendMessage () {
        
        let messageRoom = RoomMessage()
        messageRoom.to = user.username
        messageRoom.from = UserAuth.getSavedObject()!.username
        messageRoom.date = Date()
        messageRoom.message = messageTextField.text ?? ""
        let realm = try! Realm()
        if let lastObject = realm.objects(RoomMessage.self).last {
            messageRoom.id = lastObject.id + 1
        }
        try! realm.write {
            realm.add(messageRoom)
            
            self.roomMessages = RoomMessage.getMessagesForUsers(id1: self.user.username, id2: UserAuth.getSavedObject()!.username)
            DispatchQueue.main.async {
                self.chatTableView.reloadData()
                self.chatTableView.scrollToBottom(animated: true)
            }
        }
        
        XMPPController.shared.sendMessage(user: user.username+"@yahdeh",body:messageTextField.text ?? "",type: .chat)
    }
    
    @objc func sendPhoto() {
        self.present(self.photoPicker, animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.activity.startAnimating()
        guard let _data = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage).pngData() else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        DataAdapter.uploadFile(data: _data) { (file, error) in
            
            self.photoPicker.dismiss(animated: true, completion: nil)
            self.activity.stopAnimating()
            
            if error == nil {
                XMPPController.shared.sendFile(user: self.user.username+"@yahdeh", type: .chat, file: file!)
                self.view.makeToast("success sending image")
            }
            else {
                self.view.makeToast(error)
            }
            
        }
        
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        
        let messageRoom = RoomMessage()
        messageRoom.to = message.to!.user!
        messageRoom.from = message.from!.user!
        messageRoom.date = Date()
        guard let _ = message.body else {
            return
        }
        messageRoom.message = message.body!
        messageRoom.nick = message.from?.full.components(separatedBy: "/").last ?? ""
        if let attachment = message.element(forName: "attachment") {
            let realm = try! Realm()
            let file = File()
            file.name = attachment.element(forName: "name")?.stringValue ?? ""
            file.type = attachment.element(forName: "type")?.stringValue ?? ""
            file.size = attachment.element(forName: "size")?.stringValueAsNSInteger() ?? 0
            file.ext = attachment.element(forName: "ext")?.stringValue ?? ""
            file.duration = attachment.element(forName: "duration")?.stringValueAsNSInteger() ?? 0
            file.pages = attachment.element(forName: "pages")?.stringValueAsNSInteger() ?? 0
            file.thumb = attachment.element(forName: "thumb")?.stringValue ?? ""
            if let lastObject = realm.objects(File.self).last {
                file.id = lastObject.id + 1
            }
            messageRoom.file = file
        }
        
        DispatchQueue.main.async {
            let realm = try! Realm()
            if let lastObject = realm.objects(RoomMessage.self).last {
                messageRoom.id = lastObject.id + 1
            }
            try! realm.write {
                realm.add(messageRoom)
                
                self.roomMessages = RoomMessage.getMessagesForUsers(id1: self.user.username, id2: UserAuth.getSavedObject()!.username)
                DispatchQueue.main.async {
                    self.chatTableView.reloadData()
                    self.chatTableView.scrollToBottom(animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if roomMessages == nil || roomMessages.count == 0 {
            return 50
        }
        else {
            let roomMessage = roomMessages[indexPath.row]
            if roomMessage.file == nil {
                
                var messageHeight = roomMessage.message.height(withConstrainedWidth: 100, font: UIFont.systemFont(ofSize: 13, weight: .regular))
                messageHeight = messageHeight < 30 ? 30 : messageHeight
                return messageHeight + 30
            }
            else {
                return 100
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        roomMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "roomCell") as? ChatRoomViewCell
        if cell == nil {
            cell = ChatRoomViewCell(style: .subtitle, reuseIdentifier: "roomCell")
        }
        cell?.showUserFrom = false
        cell?.room = roomMessages[indexPath.row]
        cell?.roomJID = user.username+"@yahdeh"
        if roomMessages[indexPath.row].file == nil {
            cell?.addContent()
        }
        else {
            cell?.addContentFile()
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let roomMessage = roomMessages[indexPath.row]
        if let file = roomMessage.file {
            
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(file.name)

            if FileManager.default.fileExists(atPath: path.path) == false {
                self.view.makeToast("Downloading file")
                DataAdapter.downloadFile(name: file.name) { (data, error) in
                    if error == nil {
                        do {
                            try data?.write(to: path, options: .atomic)
                            DispatchQueue.main.async {
                                self.showImage(image: UIImage(data: data!)!)
                            }
                        }
                        catch _ {
                            
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.view.makeToast("Error downloading file")
                        }
                    }
                }
            }
            else {
                showImage(image: UIImage(data: try! Data(contentsOf: path))!)
            }
        }
    }
    func showImage(image:UIImage) {
        
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width*0.66, height: self.view.bounds.size.width*0.66)
        imageView.contentMode = .scaleAspectFill
        self.view.showToast(imageView)
    }
    
    @objc func sendRequestToUser() {
        
        DataAdapter.addToRoster(userName:user.username) { (statusCode, error) in
            
            if error != nil {
                self.view.makeToast("Error adding friend")
            }
            else if statusCode! < 300 {
                self.view.makeToast("Friend request is sent")
            }
            else {
                self.view.makeToast("Error with status code:\(statusCode!)")
            }
        }
    }
}
