//
//  ViewController.swift
//  YahdehDemo
//
//  Created by iMac on 2/4/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift

class ViewController:UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var token = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        if token == nil {
            let loginCon = LoginViewController()
            self.present(loginCon, animated: true) {
                token = RegsitrationCompleteData.getSavedObject()?.accessToken
            }
        }
        else if UserAuth.getSavedObject() == nil {
            
            DataAdapter.authMe { (result, err) in
                result?.witeToRealm()
                
            }
        }
        else {
            XMPPController.shared.connect(for: "\(UserAuth.getSavedObject()!.username)@yahdeh", and: RegsitrationCompleteData.getSavedObject()!.xmppToken)
        }
        
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create Tab one
        let tabOne = UINavigationController(rootViewController: RoomViewController())
        let tabOneBarItem = UITabBarItem(title: "Rooms", image: UIImage(named: "defaultImage.png"), selectedImage: UIImage(named: "selectedImage.png"))
        tabOne.tabBarItem = tabOneBarItem
         
        // create Tab two
        let tabTwo = UINavigationController(rootViewController: UsersViewController())
        let tabTwoBarItem = UITabBarItem(title: "Users", image: UIImage(named: "defaultImage.png"), selectedImage: UIImage(named: "selectedImage.png"))
        tabTwo.tabBarItem = tabTwoBarItem
        
        // create Tab three
        let tabThree = UINavigationController(rootViewController: ContactsViewController())
        let tabThreeBarItem = UITabBarItem(title: "Contacts", image: UIImage(named: "defaultImage.png"), selectedImage: UIImage(named: "selectedImage.png"))
        tabThree.tabBarItem = tabThreeBarItem
        self.viewControllers = [tabOne,tabTwo,tabThree]
        
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}

