//
//  ChatRoomViewCell.swift
//  YahdehDemo
//
//  Created by iMac on 2/11/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit

class ChatRoomViewCell : UITableViewCell {
    
    var room : RoomMessage!
    var roomJID : String!
    let messageLabel = UILabel()
    let bubbleView = UIView()
    var showUserFrom = true

    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        
        let strData = imageBase64String.dropFirst(23)
        
        let imageData = Data.init(base64Encoded: String(strData), options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func addContent() {
        bubbleView.viewWithTag(3)?.removeFromSuperview()
        bubbleView.viewWithTag(2)?.removeFromSuperview()
        messageLabel.text = room.message
        let username = UserAuth.getSavedObject()!.username
        let fromMe = room.from == username ? true : false
        
        var messageHeight = room.message.height(withConstrainedWidth: 100, font: UIFont.systemFont(ofSize: 13, weight: .regular))
        messageHeight = messageHeight < 30 ? 30 : messageHeight
        
        bubbleView.backgroundColor = fromMe == true ? UIColor.lightGray : UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        bubbleView.layer.cornerRadius = 4
        bubbleView.layer.masksToBounds = true
        bubbleView.snp.removeConstraints()
        bubbleView.snp.makeConstraints { (make) in
            make.width.equalTo(140)
            make.height.equalTo(messageHeight + 20)
            if fromMe == true {
                make.right.equalTo(self.snp.right).offset(-8)
            }
            else {
                make.left.equalTo(self.snp.left).offset(8)
            }
            make.centerY.equalTo(self.snp.centerY)
        }
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.textColor = fromMe == true ? UIColor.white : UIColor.darkGray
        messageLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        messageLabel.textAlignment = .left
        messageLabel.snp.removeConstraints()
        messageLabel.numberOfLines = 0
        messageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(4)
            make.centerY.equalTo(bubbleView.snp.centerY)
            make.width.equalTo(125)
            make.height.equalTo(messageHeight)
        }
        if fromMe == false && showUserFrom == true{
            let usernameLable = UILabel()
            bubbleView.addSubview(usernameLable)
            usernameLable.tag = 2
            usernameLable.backgroundColor = UIColor.clear
            usernameLable.textColor = UIColor.darkGray
            usernameLable.font = UIFont.systemFont(ofSize: 11, weight: .thin)
            usernameLable.textAlignment = .right
            usernameLable.text = room.nick
            usernameLable.snp.removeConstraints()
            usernameLable.snp.makeConstraints { (make) in
                make.right.equalTo(bubbleView.snp.right).offset(-4)
                make.bottom.equalTo(bubbleView.snp.bottom)
                make.width.equalTo(80)
                make.height.equalTo(18)
            }
        }
    }
    func addContentFile() {

        bubbleView.viewWithTag(3)?.removeFromSuperview()
        bubbleView.viewWithTag(2)?.removeFromSuperview()
        
        let username = UserAuth.getSavedObject()!.username
        let fromMe = room.from == username ? true : false
        bubbleView.backgroundColor = fromMe == true ? UIColor.lightGray : UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        bubbleView.layer.cornerRadius = 4
        bubbleView.layer.masksToBounds = true
        bubbleView.snp.removeConstraints()
        bubbleView.snp.makeConstraints { (make) in
            make.width.equalTo(96)
            make.height.equalTo(96)
            if fromMe == true {
                make.right.equalTo(self.snp.right).offset(-8)
            }
            else {
                make.left.equalTo(self.snp.left).offset(8)
            }
            make.centerY.equalTo(self.snp.centerY)
        }
        
        let imageView = UIImageView(image: convertBase64StringToImage(imageBase64String: room.file!.thumb))
        imageView.tag = 3
        imageView.contentMode = .scaleAspectFill
        bubbleView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.width.equalTo(94)
            make.width.equalTo(94)
            make.center.equalTo(bubbleView.snp.center)
        }
        
        if fromMe == false && showUserFrom == true{
            let usernameLable = UILabel()
            bubbleView.addSubview(usernameLable)
            usernameLable.tag = 2
            usernameLable.backgroundColor = UIColor.clear
            usernameLable.textColor = UIColor.white
            usernameLable.font = UIFont.systemFont(ofSize: 11, weight: .thin)
            usernameLable.textAlignment = .right
            usernameLable.text = room.nick
            usernameLable.snp.removeConstraints()
            usernameLable.snp.makeConstraints { (make) in
                make.right.equalTo(bubbleView.snp.right).offset(-4)
                make.bottom.equalTo(bubbleView.snp.bottom)
                make.width.equalTo(80)
                make.height.equalTo(18)
            }
        }

      }
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        self.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
