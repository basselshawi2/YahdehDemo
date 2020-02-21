//
//  LoginViewController.swift
//  YahdehDemo
//
//  Created by iMac on 2/5/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController:UIViewController {
    
    let register = RegisterationView(frame:CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(register)
        register.snp.makeConstraints { (make) in
            make.width.equalTo(400)
            make.height.equalTo(300)
            make.center.equalTo(self.view.snp.center)
            
        }
        self.view.backgroundColor = darkRedColor
    }
}
