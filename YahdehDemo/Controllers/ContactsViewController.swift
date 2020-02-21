//
//  ContactsViewController.swift
//  YahdehDemo
//
//  Created by iMac on 2/10/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit

class ContactsViewController : UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    let requestsTableView = UITableView()
    var outReqs : [RosterRequest] = []
    var inReqs : [RosterRequest] = []
    var contacts : [RosterRequest] = []
    
    override func viewDidLoad() {
        
        self.title = "Contacts"
        super.viewDidLoad()
        requestsTableView.delegate = self
        requestsTableView.dataSource = self
        self.view.addSubview(requestsTableView)
        requestsTableView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalTo(self.view.snp.bottom).offset(-50)
            make.top.equalTo(self.view.snp.top).offset(64)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataAdapter.rosterRequest(type: .incoming) { (reqs, error) in
            if error == nil {
                self.inReqs = reqs!
                DispatchQueue.main.async {
                    self.requestsTableView.reloadData()
                }
            }
        }
        
        DataAdapter.rosterRequest(type: .outgoing) { (reqs, error) in
            if error == nil {
                self.outReqs = reqs!
                DispatchQueue.main.async {
                    self.requestsTableView.reloadData()
                }
            }
        }
        DataAdapter.getRosters { (contacts, error) in
            if error == nil {
                self.contacts = contacts!
                DispatchQueue.main.async {
                    self.requestsTableView.reloadData()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Incoming"
        }
        else if section == 1 {
            return "Outgoing"
        }
        else {
            return "Contacts"
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return inReqs.count
        }
        else if section == 1 {
            return outReqs.count
        }
        else {
            return contacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var indentifier = ""
        switch indexPath.section {
        case 0:
            indentifier = "reqCellAccept"
        case 1:
            indentifier = "reqCellDecline"
        case 2:
            indentifier = "contactsCell"
        default:
            break
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier)
        if cell == nil {
            if indexPath.section == 0 {
                cell = IncomingRequestViewCell(style: .subtitle, reuseIdentifier: "reqCellAccept")
            }
            else if indexPath.section == 1 {
                cell = OutgoingRequestViewCell(style: .subtitle, reuseIdentifier: "reqCellDecline")
            }
            else {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "contactsCell")
            }
        }
        
        if indexPath.section == 0 {
            
            (cell as! IncomingRequestViewCell).request = inReqs[indexPath.row]
            (cell as! IncomingRequestViewCell).addContent()
        }
        else if indexPath.section == 1 {
            (cell as! OutgoingRequestViewCell).request = outReqs[indexPath.row]
            (cell as! OutgoingRequestViewCell).addContent()
        }
        else {
            cell?.textLabel?.text = contacts[indexPath.row].user!.username
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            let contact = contacts[indexPath.row]
            let userChat = UserChatViewController()
            userChat.friendIsAdded = true
            userChat.user = contact.user
            self.navigationController?.pushViewController(userChat, animated: true)
            
        }
    }
    
}
