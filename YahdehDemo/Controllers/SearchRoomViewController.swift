//
//  SearchRoomViewController.swift
//  YahdehDemo
//
//  Created by iMac on 2/10/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class SearchRoomViewController:UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource {
    var rooms : [Room] = []
    let searchBar = UISearchBar()
    let searchTableView = UITableView()
    let activity = NVActivityIndicatorView(frame: CGRect.zero, type: .ballPulseRise, color: darkRedColor, padding: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        searchBar.delegate = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        let _searchButton = UIButton(type: .roundedRect)
        _searchButton.setTitle("Search", for: .normal)
        _searchButton.setTitleColor(darkRedColor, for: .normal)
        _searchButton.addTarget(self, action: #selector(self.searchButton), for: .touchUpInside)
        
        self.view.addSubview(_searchButton)
        self.view.addSubview(searchTableView)
        
        searchTableView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.view.snp.top).offset(64)
            make.bottom.equalTo(_searchButton.snp.top).offset(8)
        }
        
        _searchButton.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(35)
            make.bottom.equalTo(self.view.snp.bottom).offset(-50)
            make.centerX.equalTo(self.view.snp.centerX)
        }
        
        searchTableView.tableHeaderView = searchBar
        searchBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 50)
        searchBar.placeholder = "Name of room to search"
        
        self.view.addSubview(activity)
        activity.snp.makeConstraints { (make) in
            make.center.equalTo(self.view.snp.center)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "searchRoomCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "searchRoomCell")
            cell?.textLabel?.text = rooms[indexPath.row].title
            let joinRoomButton = UIButton(type: .roundedRect)
            joinRoomButton.setTitle("Join", for: .normal)
            joinRoomButton.setTitleColor(UIColor.white, for: .normal)
            joinRoomButton.backgroundColor = darkGreenColor
            joinRoomButton.layer.cornerRadius = 3
            joinRoomButton.layer.masksToBounds = true
            joinRoomButton.addTarget(self, action: #selector(self.joinRoom(sender:)), for: .touchUpInside)
            cell?.contentView.addSubview(joinRoomButton)
            joinRoomButton.snp.makeConstraints { (make) in
                make.width.equalTo(60)
                make.height.equalTo(30)
                make.centerY.equalTo(cell!.contentView.snp.centerY)
                make.right.equalTo(cell!.contentView.snp.right).offset(-4)
            }
        }
        return cell!
    }
    
    @objc func searchButton () {
        
        activity.startAnimating()
        DataAdapter.searchRoomsFor(query: searchBar.text ?? "") { (rooms, error) in
            if error == nil {
                self.rooms = rooms!
                self.searchTableView.reloadData()
                self.searchBar.resignFirstResponder()
                self.activity.stopAnimating()
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchButton()
    }
    @objc func joinRoom (sender:UIButton) {
        
        let index = searchTableView.indexPath(for: (sender.superview?.superview as! UITableViewCell))?.row
        let room = rooms[index!]
        DataAdapter.joinRoom(id: room.id) { (room, error) in
            if error != nil {
                self.view.makeToast(error)
            }
            else {
                self.view.makeToast("Room Joined")
            }
        }
        
    }
}
