//
//  UsersViewController.swift
//  YahdehDemo
//
//  Created by iMac on 2/9/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class UsersViewController : UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var users:[User] = []
    let searchBar = UISearchBar()
    let usersTableView = UITableView()
    let activity = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: .ballBeat, color: darkRedColor, padding: nil)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "userCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "userCell")
        }
        
        cell?.textLabel?.text = users[indexPath.row].username
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        let userViewController = UserChatViewController()
        userViewController.user = user
        self.navigationController?.pushViewController(userViewController, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(usersTableView)
        usersTableView.snp.makeConstraints { (make) in
            make.top.equalTo(64)
            make.right.equalTo(self.view.snp.right)
            make.left.equalTo(self.view.snp.left)
        }
        
        
        let searchButton = UIButton(type: .roundedRect)
        searchButton.setTitle("Search", for: .normal)
        searchButton.setTitleColor(darkRedColor, for: .normal)
        self.view.addSubview(searchButton)
        searchButton.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(35)
            make.centerX.equalTo(self.view.snp.centerX)
            make.bottom.equalTo(self.view.snp.bottom).offset(-52)
            make.top.equalTo(usersTableView.snp.bottom).offset(8)
        }
        searchButton.addTarget(self , action: #selector(self.searchButtonClicked), for: .touchUpInside)
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        searchBar.delegate = self
        searchBar.placeholder = "enter username to search"
        searchBar.bounds = CGRect(x: 0, y: 0, width: usersTableView.bounds.size.width, height: 50)
        usersTableView.tableHeaderView = searchBar
        
        self.view.addSubview(activity)
        activity.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.center.equalTo(self.view.snp.center)
        }
    }
    
    @objc func searchButtonClicked() {
        searchBarSearchButtonClicked(searchBar)
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        activity.startAnimating()
        DataAdapter.searchUserFor(query: searchBar.text ?? "") { (users, error) in
            
            if error == nil {
                self.users = users!
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.usersTableView.reloadData()
                    self.searchBar.resignFirstResponder()
                }
            }
        }
        
    }
}
