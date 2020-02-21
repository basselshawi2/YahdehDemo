//
//  ChatRoomViewCell.swift
//  YahdehDemo
//
//  Created by iMac on 2/11/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import Toast_Swift

class IncomingRequestViewCell : UITableViewCell {
    
    var request : RosterRequest!
    let messageLabel = UILabel()
    let joinButton = UIButton(type: .roundedRect)
    let declineButton = UIButton(type: .roundedRect)
    
    func addContent() {
        
        messageLabel.text = request.user?.name
        messageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(8)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(140)
            make.height.equalTo(35)
        }
        messageLabel.textColor = UIColor.black
        messageLabel.backgroundColor = UIColor.clear
        
        joinButton.backgroundColor = darkGreenColor
        joinButton.setTitle("Accept", for: .normal)
        joinButton.setTitleColor(UIColor.white, for: .normal)
        joinButton.layer.cornerRadius = 4
        joinButton.layer.masksToBounds = true
        
        declineButton.backgroundColor = darkRedColor
        declineButton.setTitle("Decline", for: .normal)
        declineButton.setTitleColor(UIColor.white, for: .normal)
        declineButton.layer.cornerRadius = 4
        declineButton.layer.masksToBounds = true
        
        declineButton.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(self.snp.right).offset(-8)
        }
        
        joinButton.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(declineButton.snp.left).offset(-8)
        }
        
    }
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        self.addSubview(joinButton)
        self.addSubview(declineButton)
        self.addSubview(messageLabel)
        joinButton.addTarget(self, action: #selector(self.accpetUser), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(self.declineUser), for: .touchUpInside)
    }
    
    @objc func accpetUser() {
    
        declineButton.isUserInteractionEnabled = false
        joinButton.isUserInteractionEnabled = false
        DataAdapter.rosterInvite(accept: true, for: request.user!.username) { (statusCode, error) in
            
            if error != nil {
                self.makeToast(error)
            }
            else {
                self.makeToast("Friend is accepted")
            }
        }
    }
    @objc func declineUser() {

        declineButton.isUserInteractionEnabled = false
        joinButton.isUserInteractionEnabled = false
        DataAdapter.rosterInvite(accept: false, for: request.user!.username) { (statusCode, error) in
        
            if error != nil {
                self.makeToast("Error declining friend request")
            }
            else {
                self.makeToast("Friend is declined")
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
