//
//  LoginView.swift
//  YahdehDemo
//
//  Created by iMac on 2/4/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import Toast_Swift
import FlagPhoneNumber

class RegisterationView : UIView,UITextFieldDelegate {
    
    var nameTextField: UITextField!
    var usernameTextField: UITextField!
    let activity = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: .ballClipRotate, color: darkRedColor, padding: nil)
    let phoneNumberTextField = FPNTextField(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(phoneNumberTextField)
        phoneNumberTextField.setFlag(key: .SY)
        phoneNumberTextField.set(phoneNumber: "933671555")
        phoneNumberTextField.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.snp.top).offset(16)
        }
        phoneNumberTextField.textColor = .white
        nameTextField = UITextField()
        usernameTextField = UITextField()
        
        nameTextField.placeholder = "Enter name ex: Bassel Shawi"
        usernameTextField.placeholder = "Enter username ex: bassel.shawi"
  
        self.addSubview(nameTextField)
        self.addSubview(usernameTextField)
        
        nameTextField.delegate = self
        usernameTextField.delegate = self
        
        nameTextField.snp.makeConstraints { (make) in
            make.width.equalTo(220)
            make.height.equalTo(35)
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(16)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        usernameTextField.snp.makeConstraints { (make) in
            make.width.equalTo(220)
            make.height.equalTo(35)
            make.top.equalTo(nameTextField.snp.bottom).offset(16)
            make.centerX.equalTo(self.snp.centerX)
        }
     
        let registerButton = UIButton(type: .roundedRect)
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.addTarget(self, action: #selector(self.registerMobile), for: .touchUpInside)
        self.addSubview(registerButton)
        registerButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(usernameTextField.snp.bottom).offset(32)
            
        }
        
        
        usernameTextField.borderStyle = .roundedRect
        nameTextField.borderStyle = .roundedRect

        self.addSubview(activity)
        activity.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.center.equalTo(self.snp.center)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    func createAccount() {
        
        var phoneCode = phoneNumberTextField.selectedCountry?.phoneCode
        phoneCode?.removeFirst()
        
        activity.startAnimating()
        DataAdapter.createAccount(countryCode: phoneCode ?? "", mobileNumber: phoneNumberTextField.getRawPhoneNumber() ?? "") { (token, error) in
            if error == nil {
                DataAdapter.checkOTP(countryCode: phoneCode ?? "", phone: self.phoneNumberTextField.getRawPhoneNumber() ?? "", token: token!) { (result, error) in
                    if error == nil {
                        let userDefaults = UserDefaults.standard
                        userDefaults.set(result?.accessToken, forKey: "token")
                        userDefaults.synchronize()
                        self.finishAccountCreation()
                    }
                    else {
                        self.makeToast("Error Getting OTP")
                        self.activity.stopAnimating()
                    }
                }
            }
            else {
                self.makeToast("Error Creating Account")
                self.activity.stopAnimating()
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var textFiledNotTouched = false
        for touch in touches {
            if let targetHit = hitTest(touch.location(in: self), with: event) {
                if targetHit == usernameTextField ||
                    targetHit == nameTextField ||
                    targetHit == phoneNumberTextField {
                    textFiledNotTouched = true
                }
            }
        }
        if textFiledNotTouched == false {
            usernameTextField.resignFirstResponder()
            phoneNumberTextField.resignFirstResponder()
            nameTextField.resignFirstResponder()
        }
    }
    func finishAccountCreation() {
        DataAdapter.completeRegistration(name: nameTextField.text ?? "", username: usernameTextField.text ?? "") { (result, error) in
            
            if error == nil {
                
                result?.witeToRealm()
            }
            else {
                self.makeToast("Error completing creation")
            }
            self.activity.stopAnimating()
            self.findViewController()?.dismiss(animated: true, completion: nil)
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func registerMobile() {
        
      createAccount()
        
    }

}
