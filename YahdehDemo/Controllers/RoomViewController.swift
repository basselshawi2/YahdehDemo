//
//  RoomViewController.swift
//  YahdehDemo
//
//  Created by iMac on 2/6/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import NVActivityIndicatorView

public class RoomViewController : UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var rooms : [Room] = []
    let roomsTableView = UITableView()
    let activity = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: .ballPulse, color: darkRedColor, padding: nil)
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rooms.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "roomCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "roomCell")
        }
         
        cell?.textLabel?.text = rooms[indexPath.row].name
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let room = rooms[indexPath.row]
        let chatroomViewController = ChatRoomViewController()
        chatroomViewController.roomJID = room.jid
        chatroomViewController.roomID = room.id
        DispatchQueue.main.async {    
            self.navigationController?.pushViewController(chatroomViewController, animated: true)
        }
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let createButton = UIButton(type: .roundedRect)
        createButton.setTitle("Create New Room", for: .normal)
        createButton.addTarget(self, action: #selector(self.createNewRoom), for: .touchUpInside)
        createButton.setTitleColor(darkRedColor, for: .normal)
        self.view.addSubview(createButton)
        createButton.snp.makeConstraints { (make) in
            make.width.equalTo(130)
            make.height.equalTo(35)
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(self.view.snp.top).offset(64)
        }
        
        self.view.addSubview(roomsTableView)
        roomsTableView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.top.equalTo(createButton.snp.bottom)
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
           
        }
        self.view.addSubview(activity)
        activity.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.center.equalTo(self.view.snp.center)
        }
        
        roomsTableView.delegate = self
        roomsTableView.dataSource = self
        self.view.backgroundColor = UIColor.white
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.searchRoom))
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activity.startAnimating()
        DataAdapter.getRooms { (rooms, error) in
            self.activity.stopAnimating()
            if let _rooms = rooms {
                self.rooms = _rooms
                self.roomsTableView.reloadData()
            }
            else {
                self.view.makeToast("error getting rooms")
                 
            }
        }
    }

    
    @objc func createNewRoom() {
        let newRoom = CreateRoomViewController()
        
        self.navigationController?.pushViewController(newRoom, animated: true)
    }
    
    @objc func searchRoom() {
        let searchRoomController = SearchRoomViewController()
        searchRoomController.title = "Search"
        self.navigationController?.pushViewController(searchRoomController, animated: true)
    }
    
}
