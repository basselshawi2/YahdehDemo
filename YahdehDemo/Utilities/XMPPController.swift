//
//  XMPPController.swift
//  YahdehDemo
//
//  Created by iMac on 2/4/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import XMPPFramework

class XMPPController : NSObject {
    
    public var xmppStream: XMPPStream
    let reconnect:XMPPReconnect = XMPPReconnect()
    let outgooingFile = XMPPOutgoingFileTransfer(dispatchQueue: DispatchQueue.main)
    let incomingFile = XMPPIncomingFileTransfer(dispatchQueue: DispatchQueue.main)
    
    static private var xmpController : XMPPController!
    private var password:String!
    
    private override init() {
        self.xmppStream = XMPPStream()
        
    }
    
    public static var shared: XMPPController = {
        
        xmpController = XMPPController()
        return xmpController
    }()
    
    func sendMessage(user:String,body:String,type:XMPPMessage.MessageType) {
        let message = XMPPMessage(messageType: type, to: XMPPJID(string: user), elementID: nil, child: nil)
        
        message.addBody(body)
        xmppStream.send(message)
    
    }
    
    func sendFile(user:String,type:XMPPMessage.MessageType,file:File) {
        
        let attachment = DDXMLElement(name: "attachment", xmlns: "attachment")
        let name = DDXMLElement(name: "name", stringValue: file.name)
        let fileType = DDXMLElement(name: "type", stringValue: file.type)
        let size = DDXMLElement(name: "size", stringValue: "\(file.size)")
        let ext = DDXMLElement(name: "ext", stringValue: file.ext)
        let duration = DDXMLElement(name: "duration", stringValue: "\(file.duration)")
        let pages = DDXMLElement(name: "pages", stringValue: "\(file.pages)")
        let thumb = DDXMLElement(name: "thumb", stringValue: file.thumb)
        attachment.addChild(name)
        attachment.addChild(fileType)
        attachment.addChild(size)
        attachment.addChild(ext)
        attachment.addChild(duration)
        attachment.addChild(pages)
        attachment.addChild(thumb)
        
        let message = XMPPMessage(messageType: type, to: XMPPJID(string: user), elementID: nil, child: attachment)
        message.addBody("Image")
        print(message)
        xmppStream.send(message)
    
    }
    
    func sendPresence(user:String) {
        let presence = XMPPPresence(type: "available", to: XMPPJID(string: user))
        xmppStream.send(presence)
        
    }
    func connect(for userName:String,and password:String)->Bool {
        
        self.password = password
        xmppStream.hostName = "dev-api.yahdeh.com"
        xmppStream.hostPort = 5222
        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.global())
        
        if xmppStream.isDisconnected == false {
            return true
        }
        
        xmppStream.myJID = XMPPJID(string:userName)
        reconnect.activate(xmppStream)
        do {
            try xmppStream.connect(withTimeout: 30)
        }
        catch let err {
            print(err.localizedDescription)
        }
        outgooingFile.activate(self.xmppStream)
        outgooingFile.addDelegate(self, delegateQueue: DispatchQueue.main)
        incomingFile.activate(self.xmppStream)
        incomingFile.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        return true
    }
}

extension XMPPController:XMPPStreamDelegate,XMPPOutgoingFileTransferDelegate,XMPPIncomingFileTransferDelegate {
    
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        print("connected")
        do {
            try xmppStream.authenticate(withPassword: password)
        }
        catch _ {
            
        }
    }
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        self.xmppStream.send(XMPPPresence())
        print("Stream: Authenticated")
        let presence = XMPPPresence()
        self.xmppStream.send(presence)
    }
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        print("message sent")
    }
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("message received")
    }
    func xmppStream(_ sender: XMPPStream, didSend presence: XMPPPresence) {
        print("presence sent")
    }
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        print("timed out")
    }
    func xmppOutgoingFileTransferDidSucceed(_ sender: XMPPOutgoingFileTransfer!) {
        print("fiel transfer succeed")
    }
    func xmppOutgoingFileTransfer(_ sender: XMPPOutgoingFileTransfer!, didFailWithError error: Error!) {
        print(error.debugDescription)
    }
    func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer!, didFailWithError error: Error!) {
        let err = 3
    }
    func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer!, didSucceedWith data: Data!, named name: String!) {
        let data = 32
    }
//Only occupants are allowed to send queries to the conference
}
