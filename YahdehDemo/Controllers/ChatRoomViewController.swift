//
//  ChatRoomViewController.swift
//  YahdehDemo
//
//  Created by iMac on 2/6/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit
import XMPPFramework
import RealmSwift
import NVActivityIndicatorView

class ChatRoomViewController : UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,XMPPStreamDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let chatTableView = UITableView()
    let messageTextField = UITextField()
    var roomJID : String!
    var roomID : Int!
    var roomMessages:[RoomMessage]!
    let photoPicker = UIImagePickerController()
    var presenceTimer : Timer!
    let activity = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: .ballPulse, color: darkRedColor, padding: nil)
    
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        roomMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "roomCell") as? ChatRoomViewCell
        if cell == nil {
            cell = ChatRoomViewCell(style: .subtitle, reuseIdentifier: "roomCell")
        }
        cell?.room = roomMessages[indexPath.row]
        cell?.roomJID = roomJID
        if roomMessages[indexPath.row].file == nil {
            cell?.addContent()
        }
        else {
            cell?.addContentFile()
        }
        
        return cell!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        XMPPController.shared.xmppStream.addDelegate(self , delegateQueue: DispatchQueue.main)
        
        presenceTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (timier) in
            XMPPController.shared.sendPresence(user: "\(self.roomJID!)/\(UserAuth.getSavedObject()!.name.trimmingCharacters(in: .whitespacesAndNewlines))")
        })
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        XMPPController.shared.xmppStream.removeDelegate(self, delegateQueue: DispatchQueue.main)
        presenceTimer?.invalidate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let roomID = roomJID.components(separatedBy: "@conference.yahdeh").first
        roomMessages = RoomMessage.getMessagesForRoom(id: roomID!)
        
        self.title = "Room"
        
        photoPicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        photoPicker.sourceType = .photoLibrary
        photoPicker.modalPresentationStyle = .overCurrentContext

        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.backgroundColor = UIColor.clear
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
            make.top.equalTo(self.view.snp.top).offset(64)
        }
        
        self.view.backgroundColor = UIColor.white
        self.chatTableView.scrollToBottom(animated: true)
        
        photoPicker.view.addSubview(activity)
        activity.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.center.equalTo(photoPicker.view.snp.center)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
            
            picker.dismiss(animated: true) {
                self.activity.stopAnimating()
            }
            if error == nil {
                XMPPController.shared.sendFile(user: self.roomJID, type: .groupchat, file: file!)
                self.view.makeToast("success sending image")
            }
            else {
                self.view.makeToast(error)
            }
            
        }
        
    }
    @objc func sendMessage () {
        
        XMPPController.shared.sendMessage(user: roomJID,body:messageTextField.text ?? "",type: .groupchat)
    }

    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
     
        print(message)
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
                let roomID = self.roomJID.components(separatedBy: "@conference.yahdeh").first
                self.roomMessages = RoomMessage.getMessagesForRoom(id: roomID!)
                DispatchQueue.main.async {
                    self.chatTableView.reloadData()
                    self.chatTableView.scrollToBottom(animated: true)
                }
            }
        }
    }
}
