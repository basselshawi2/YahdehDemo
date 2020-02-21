//
//  ChatRoomViewCell.swift
//  YahdehDemo
//
//  Created by iMac on 2/11/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift

class OutgoingRequestViewCell : UITableViewCell {
    
    var request : RosterRequest!
    let messageLabel = UILabel()
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
        
        declineButton.backgroundColor = darkRedColor
        declineButton.setTitle("Cancel", for: .normal)
        declineButton.setTitleColor(UIColor.white, for: .normal)
        declineButton.layer.cornerRadius = 4
        declineButton.layer.masksToBounds = true
        
        declineButton.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(self.snp.right).offset(-8)
        }
        
        
    }
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        self.addSubview(declineButton)
        self.addSubview(messageLabel)
        declineButton.addTarget(self, action: #selector(self.declineUser), for: .touchUpInside)
    }

    @objc func declineUser() {
        
        declineButton.isUserInteractionEnabled = false
        DataAdapter.rosterInviteCancel(for: request.user!.username) { (statusCode, error) in
            
            if error != nil {
                self.makeToast("Error Canceling friend request")
            }
            else {
                self.makeToast("Friend request is canceled")
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
