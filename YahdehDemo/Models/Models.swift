//
//  Models.swift
//  YahdehDemo
//
//  Created by iMac on 2/4/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import RealmSwift


public class OtpResponse : Object {
    
    @objc dynamic var accessToken = ""
    @objc dynamic var id = 0
    @objc dynamic var isRegistrationCompleted = false
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}

public class RoomMessage:Object,Codable{
    
    @objc dynamic var id=0
    @objc dynamic var to = ""
    @objc dynamic var from = ""
    @objc dynamic var message = ""
    @objc dynamic var nick : String?
    @objc dynamic var date = Date()
    @objc dynamic var file : File?
    
    class func getMessagesForRoom(id:String)->[RoomMessage]? {
        let realm = try! Realm()
        return Array(realm.objects(RoomMessage.self).filter("from = '\(id)'").sorted(byKeyPath: "date", ascending: true))
         
    }
    
    class func getMessagesForUsers(id1:String,id2:String)->[RoomMessage]? {
        let realm = try! Realm()
        return Array(realm.objects(RoomMessage.self).filter("from = '\(id1)' and to = '\(id2)' or from = '\(id2)' and to = '\(id1)'").sorted(byKeyPath: "date", ascending: true))
         
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
}

public class RegsitrationCompleteData : OtpResponse {
    
    @objc dynamic var xmppHost=""
    @objc dynamic var xmppToken=""
    
    func witeToRealm() {
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(self, update: .modified)
        }
    }
    
    class func getSavedObject()->RegsitrationCompleteData? {
        
        let realm = try! Realm()
        return realm.objects(RegsitrationCompleteData.self).last
    }
   
}

public class UserSettings:Object,Codable{
    
    //@objc dynamic var newNotificationAlert = false
    @objc dynamic var roomChatAlert = false
    @objc dynamic var privateMessageAlert = false
    @objc dynamic var inAppVibrate = false
    @objc dynamic var radius = 0
}
public class User:Object,Codable {
    
    @objc dynamic var id=0
    @objc dynamic var name=""
    @objc dynamic var username = ""
    @objc dynamic var avatar : String? = ""
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
public class UserRequest:User {
    
    @objc dynamic var jid = ""
    @objc dynamic var isBlocked = false
    @objc dynamic var guardian = 0
}

public class RosterRequest : Object,Codable {
    
    @objc dynamic var id=0
    @objc dynamic var user:UserRequest?
    @objc dynamic var createdAt:String = ""
    @objc dynamic var ask:String?
    override public static func primaryKey() -> String? {
        return "id"
    }
}
public class UserAuth:User {
    
    @objc dynamic var email = ""
    @objc dynamic var countryCode = ""
    @objc dynamic var phone = ""
    @objc dynamic var settings : UserSettings?
    @objc dynamic var verified = false
    
    func witeToRealm() {
        
        let realm = try! Realm()
    
        try! realm.write {
            realm.add(self, update: .modified)
        }
    }
    
    class func getSavedObject()->UserAuth? {
        
        let realm = try! Realm()
        return realm.objects(UserAuth.self).last
    }
}

public class File:Object,Codable {
    
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var size = 0
    @objc dynamic var type = ""
    @objc dynamic var ext = ""
    @objc dynamic var thumb = ""
    @objc dynamic var duration = 0
    @objc dynamic var pages = 0
    @objc dynamic var createdAt : String?
    
    override public static func primaryKey() -> String? {
         return "id"
     }
    
}
public class Room:Object,Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case jid
        case name
        case title
        case descriptionn = "description"
        case latitude
        case longitude
        case createdAt
        case updatedAt
        case expireAt
        case owner
        case members
        case membersCount
    }
    
    @objc dynamic var id = 0
    @objc dynamic var jid = ""
    @objc dynamic var name = ""
    @objc dynamic var title = ""
    @objc dynamic var descriptionn = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    var createdAt = RealmOptional<Int>()
    var updatedAt = RealmOptional<Int>()
    var expireAt = RealmOptional<Int>()
    @objc dynamic var owner : User?
    var members = RealmSwift.List<User>()
    @objc dynamic var membersCount = 0
   
    public required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        jid = try values.decode(String.self, forKey: .jid)
        name = try values.decode(String.self, forKey: .name)
        title = try values.decode(String.self, forKey: .title)
        descriptionn = try values.decode(String.self, forKey: .descriptionn)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self,forKey: .longitude)
        do{
            createdAt = try values.decode(RealmOptional<Int>.self, forKey: .createdAt)
        }
        catch {}
        do {
            updatedAt = try values.decode(RealmOptional<Int>.self, forKey: .updatedAt)
        }
        catch {}
        do {
            expireAt = try values.decode(RealmOptional<Int>.self,forKey: .expireAt)
        }
        catch {}
        do {
            owner = try values.decode(User.self,forKey: .owner)
        }
        catch {}
        do {
            members = try values.decode(RealmSwift.List<User>.self, forKey: .members)
        }
        catch {}
        membersCount = try values.decode(Int.self, forKey: .membersCount)
        
    }
  
    required init() {
        
    }
}
