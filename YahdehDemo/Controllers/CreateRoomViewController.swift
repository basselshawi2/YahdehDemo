//
//  CreateRoomViewController.swift
//  YahdehDemo
//
//  Created by iMac on 2/8/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit

class CreateRoomViewController:UIViewController,UITextFieldDelegate {
    
    let titleTextField = UITextField()
    let descriptionTextField = UITextField()
    let longTextField = UITextField()
    let latTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        longTextField.delegate = self
        latTextField.delegate = self
        
        longTextField.keyboardType = .decimalPad
        latTextField.keyboardType = .decimalPad
        
        self.view.addSubview(titleTextField)
        self.view.addSubview(descriptionTextField)
        self.view.addSubview(longTextField)
        self.view.addSubview(latTextField)
        
        titleTextField.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(35)
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(64)
        }
        
        descriptionTextField.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(35)
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
        }
        longTextField.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(35)
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(descriptionTextField.snp.bottom).offset(8)
        }
        latTextField.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(35)
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(longTextField.snp.bottom).offset(8)
        }
        
        titleTextField.placeholder = "Title"
        descriptionTextField.placeholder = "Description"
        longTextField.placeholder = "Longitude ex:33.33"
        latTextField.placeholder = "Latitude ex:33.33"
        titleTextField.borderStyle = .roundedRect
        descriptionTextField.borderStyle = .roundedRect
        longTextField.borderStyle = .roundedRect
        latTextField.borderStyle = .roundedRect
        
        self.title = "Create Room"
        
        let createButton = UIButton(type: .roundedRect)
        createButton.setTitle("Create Room", for: .normal)
        createButton.addTarget(self, action: #selector(self.createRoom), for: .touchUpInside)
        createButton.setTitleColor(darkRedColor, for: .normal)
        self.view.addSubview(createButton)
        createButton.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(35)
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(latTextField.snp.bottom).offset(8)
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func createRoom () {
        
        DataAdapter.createRoom(title: titleTextField.text ?? "", description: descriptionTextField.text ?? "", long: longTextField.text ?? "", Lat: latTextField.text ?? "") { (statusCode, error) in
            
            if let code = statusCode {
                if code < 300 {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.view.makeToast("Error creating room, error code:\(code)")
                }
            }
            if error != nil {
                self.view.makeToast("Error creating room")
            }
            
        }
    }
}
