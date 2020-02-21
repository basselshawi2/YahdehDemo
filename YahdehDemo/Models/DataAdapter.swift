//
//  DataAdapter.swift
//  YahdehDemo
//
//  Created by iMac on 2/4/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class DataAdapter {
    
    class func load<T:Decodable>(_ data:Data, as type:T.Type = T.self) -> T {
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            return try decoder.decode(T.self, from: data)
        }
        catch  {
            print(error)
            fatalError("coulnd't decode")
        }
        
    }
    
    class public func createAccount(countryCode:String,mobileNumber:String,completionHanlder:@escaping (_ result:Int?,_ error:String?)->()) {
    
        let url = URL(string: "http://dev-api.yahdeh.com/api/auth")
        let parameter = ["countryCode":countryCode,"phone":mobileNumber]
        
        if let urlReq = url {
            Alamofire.request(urlReq,
                              method: .post,
                              parameters:parameter,encoding:URLEncoding.httpBody)
                .validate()
                .responseJSON { (result) in
                    switch result.result {
                    case .success(let value) :
                        let json = JSON(value)
                        
                        completionHanlder(json["nextTokenIn"].int,nil)
                        return
                    case .failure(let error):
                        completionHanlder(nil,"error creating account"+error.localizedDescription)
                        
                    }
            }
        }
    }

    class public func checkOTP(countryCode:String,phone:String,token:Int,completionHandler:@escaping(_ result:OtpResponse?,_ error:String?)->()) {
    
        let url = URL(string: "http://dev-api.yahdeh.com/api/auth/otp")
        let parameters = ["countryCode":countryCode,"phone":phone,"token":"\(token)","platform":"iOS","fcmToken":NSUUID().uuidString.lowercased()]
        if let urlReq = url {
            Alamofire.request(urlReq,method:.post,parameters: parameters,encoding: URLEncoding.httpBody)
            .validate()
                .responseJSON { (result) in
                    switch result.result {
                    case .success(let val):
                        let json = JSON(val)
                        let otpData = OtpResponse()
                        otpData.accessToken = json["accessToken"].stringValue
                        otpData.id = json["id"].intValue
                        otpData.isRegistrationCompleted = json["isRegistrationCompleted"].boolValue
                        
                        completionHandler(otpData,nil)
                    case .failure(let err):
                        completionHandler(nil,err.localizedDescription)
                    }
            }
        }
        
    }
    
    class public func completeRegistration(name:String,username:String,completionHandler :@escaping(_ result:RegsitrationCompleteData?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/auth/complete")
        let token = UserDefaults.standard.string(forKey: "token")!
        let header = ["Authorization":token]
        let parameters = ["name":name,"username":username,"fcmToken":NSUUID().uuidString.lowercased(),"platform":"iOS"]
        Alamofire.request(url!,method: .post,parameters:parameters,encoding: URLEncoding.httpBody,headers: header)
            .validate()
            .responseJSON { (result) in
                switch result.result {
                case .success(let val):
                    let json = JSON(val)
                    let regData = RegsitrationCompleteData()
                    regData.accessToken = json["accessToken"].stringValue
                    regData.id = json["id"].intValue
                    regData.isRegistrationCompleted = json["isRegistrationCompleted"].boolValue
                    regData.xmppHost = json["xmppHost"].stringValue
                    regData.xmppToken = json["xmppToken"].stringValue
                    completionHandler(regData,nil)
                case .failure(let err):
                    completionHandler(nil,err.localizedDescription)
                }
        }
    }
    class public func authMe(completionHandler:@escaping (_ user:UserAuth?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/auth/me")!
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        guard let token = accessToken else {
            completionHandler(nil,"empty token")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(url,method: .get,headers: header)
        .validate()
            .responseString { (result) in
                guard let dataRaped = result.data else  {
                    completionHandler(nil,"error")
                    return
                }
                let resultMapped = DataAdapter.load(dataRaped, as: UserAuth.self)
                completionHandler(resultMapped,nil)
        }
    }
    
    class public func getRooms(completionHanlder:@escaping (_ rooms:[Room]?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/room")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHanlder(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHanlder(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .get,headers: header)
            .validate()
            .responseString { (result) in
                
                if let resp = result.response  {
                    if resp.statusCode >= 300 {
                        completionHanlder(nil,"error")
                        return
                    }
                }
                guard let dataRaped = result.data else {
                    completionHanlder(nil,"error")
                    return
                }
                let resultMapped = DataAdapter.load(dataRaped, as: [Room].self)
                completionHanlder(resultMapped,nil)
        }
    }
    
    class public func searchRoomsFor(query:String,completionHanlder:@escaping (_ rooms:[Room]?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/room/search/\(query)")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHanlder(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHanlder(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .get,headers: header)
            .validate()
            .responseString { (result) in
                guard let dataRaped = result.data else {
                    completionHanlder(nil,"error")
                    return
                }
                let resultMapped = DataAdapter.load(dataRaped, as: [Room].self)
                completionHanlder(resultMapped,nil)
        }
    }
    
    class public func createRoom(title:String,description:String,long:String,Lat:String,completionHandler:@escaping (_ statusCode:Int?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/room")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHandler(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let parameters = ["title":title,"description":description,"longitude":long,"latitude":Lat]
        let header = ["Authorization":"Bearer \(token)"]
        
        Alamofire.request(urlReq,method: .post,parameters: parameters,headers: header)
        .validate()
            .responseString { (result) in
                guard let _ = result.data else {
                    completionHandler(nil,"no data")
                    return
                }
                
                completionHandler(result.response?.statusCode,nil)
        }
    }
    
    class public func searchUserFor(query:String,completionHandler:@escaping(_ users:[User]?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/user/search/\(query)")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHandler(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .get,headers: header)
            .validate()
            .responseString { (result) in
                guard let rapedData = result.data else {
                    completionHandler(nil,"no data")
                    return
                }
                let resultMaped = DataAdapter.load(rapedData, as: [User].self)
                completionHandler(resultMaped,nil)
        }
    }
    
    class public func addToRoster(userName:String,completionHandler:@escaping (_ statusCode:Int?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/roster/add/\(userName)")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHandler(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .post,headers: header)
            .validate()
            .responseJSON { (result) in
                guard let resp = result.response else {
                    completionHandler(nil,"error")
                    return
                }
                completionHandler(resp.statusCode,nil)
        }
    }
    class public func rosterInvite(accept:Bool,for username:String,completionHandler:@escaping(_ statusCode:Int?,_ error:String?)->()) {
        
        let action = accept == true ? "accept" : "decline"
        let url = URL(string: "http://dev-api.yahdeh.com/api/roster/\(action)/\(username)")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHandler(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .post,headers: header)
            .validate()
            .responseJSON { (result) in
                
                if let resp = result.response?.statusCode {
                    if resp < 300 {
                        completionHandler(resp,nil)
                    }
                    else {
                        completionHandler(nil,"error with statuCode:\(resp)")
                    }
                }
                else {
                    completionHandler(nil,"error, no response")
                }
                
        }
        
    }
    
    class public func rosterInviteCancel(for username:String,completionHandler:@escaping(_ statusCode:Int?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/roster/cancel/\(username)")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHandler(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .post,headers: header)
            .validate()
            .responseJSON { (result) in
                
                if let resp = result.response?.statusCode {
                    if resp < 300 {
                        completionHandler(resp,nil)
                    }
                    else {
                        completionHandler(nil,"error with statuCode:\(resp)")
                    }
                }
                else {
                    completionHandler(nil,"error, no response")
                }
                
        }
        
    }
    
    class public func getRosters(completionHandler:@escaping(_ rosters:[RosterRequest]?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/roster/")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHandler(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .get,headers: header)
            .validate()
            .responseString { (result) in
                guard let dataRaped = result.data else {
                    completionHandler(nil,"error")
                    return
                }
                let resultMapped = DataAdapter.load(dataRaped, as: [RosterRequest].self)
                completionHandler(resultMapped,nil)
        }
        
    }
    
    class public func joinRoom(id:Int,completionHandler:@escaping(_ room:Room?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/room/\(id)/join/")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHandler(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .post,headers: header)
            .validate()
            .responseString { (result) in
                
                if let statusCode = result.response?.statusCode {
                    if statusCode >= 300 {
                        completionHandler(nil,"error with statusCode:\(statusCode)")
                        return
                    }
                    else {
                        if let dataRaped = result.data {
                            let resultMaped = DataAdapter.load(dataRaped, as: Room.self)
                            completionHandler(resultMaped,nil)
                        }
                        else {
                            completionHandler(nil,"error getting data")
                            return
                        }
                    }
                }
                else {
                    completionHandler(nil,"error, no response")
                    return
                }
        }
    }
    
    class public func getRoomInvitation(roomTitle:String,usrename:String,message:String,completionHandler:@escaping(_ statusCode:Int?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/invitation")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHandler(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        let parameters = ["room":roomTitle,"username":usrename,"message":message]
        
        Alamofire.request(urlReq,method: .post,parameters: parameters,headers: header)
            .validate()
            .responseJSON { (result) in
                
                if let resp = result.response?.statusCode {
                    if resp < 300 {
                        completionHandler(resp,nil)
                    }
                    else {
                        completionHandler(resp,"error with statusCode:\(resp)")
                    }
                }
                else {
                    completionHandler(nil,"error, no response")
                }
        }
        
    }
    class public func roomInvite(id:Int,accepct:Bool,completionHandler:@escaping(_ statusCode:Int?,_ error:String?)->()) {
        let action = accepct == true ? "accept" : "decline"
        let url = URL(string: "http://dev-api.yahdeh.com/api/invitation/\(id)/\(action)")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHandler(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .post,headers: header)
            .validate()
            .responseJSON { (result) in
                
                if let resp = result.response?.statusCode {
                    if resp < 300 {
                        completionHandler(resp,nil)
                    }
                    else {
                        completionHandler(nil,"error with statuCode:\(resp)")
                    }
                }
                else {
                    completionHandler(nil,"error, no response")
                }
                
        }
    }
    
    enum RosterRequestType:String {
        case incoming = "incoming"
        case outgoing = "outgoing"
    }
    class public func rosterRequest(type:RosterRequestType,completionHanlder:@escaping (_ rooms:[RosterRequest]?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/roster/\(type.rawValue)")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHanlder(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHanlder(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .get,headers: header)
            .validate()
            .responseString { (result) in
                guard let dataRaped = result.data else {
                    completionHanlder(nil,"error")
                    return
                }
                let resultMapped = DataAdapter.load(dataRaped, as: [RosterRequest].self)
                completionHanlder(resultMapped,nil)
        }
    }
   
    class public func uploadFile(data:Data,completionHandler:@escaping(_ file:File?,_ error:String?)->()) {
        
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken

        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]

        SRWebClient.POST("http://dev-api.yahdeh.com/api/file").data(data, fieldName: "file", data: nil).headers(header).send({(response:Any!, status:Int) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                guard let _data = (response as! String).data(using: .utf8) else {
                    return
                }
                let file = DataAdapter.load(_data, as: File.self)
                completionHandler(file,nil)
            })
        },failure:{(error:NSError!) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                completionHandler(nil, error.localizedDescription)
            })
        })
        
    }
    
    class public func downloadFile(name:String,completionHandler:@escaping(_ data:Data?,_ error:String?)->()) {
        
        let url = URL(string: "http://dev-api.yahdeh.com/api/file/\(name)")
        let accessToken = RegsitrationCompleteData.getSavedObject()?.accessToken
        
        guard let urlReq = url else {
            completionHandler(nil,"wrong url")
            return
        }
        guard let token = accessToken else {
            completionHandler(nil,"token missing")
            return
        }
        let header = ["Authorization":"Bearer \(token)"]
        Alamofire.request(urlReq,method: .get,headers: header)
            .validate()
            .responseString { (result) in
                
                if let statusCode = result.response?.statusCode {
                    if statusCode >= 300 {
                        completionHandler(nil,"error with statusCode:\(statusCode)")
                        return
                    }
                    else {
                        if let dataRaped = result.data {
                            
                            completionHandler(dataRaped,nil)
                        }
                        else {
                            completionHandler(nil,"error getting data")
                            return
                        }
                    }
                }
                else {
                    completionHandler(nil,"error, no response")
                    return
                }
        }
    }
}
