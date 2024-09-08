//
//  SocketManager.swift
//  ChattingPractice
//
//  Created by jaegu park on 9/8/24.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    static let shared = SocketIOManager()
    var manager = SocketManager(socketURL: URL(string: "http://localhost:9000")!, config: [.log(true), .compress])
    var socket: SocketIOClient!
    
    override init() {
        super.init()
        socket = self.manager.socket(forNamespace: "\test")
        
        print("소켓 초기화 완료")
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToServerWithNickname(nickname: String, completeHandler:(@escaping ([[String: AnyObject]]) -> Void)) {
        socket.emit("connectUser", nickname)
        
        socket.on("userList") { (dataArray, ack) in
            completeHandler(dataArray[0] as! [[String: AnyObject]])
        }
    }
    
    func exitChatWithNickname(nickname:String, completeHandler: ()-> Void) {
        socket.emit("exitUser", nickname)
        completeHandler()
    }
        
    func sendMessage(message:String, withNickname nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }
        
    func getChatMessage(completHandler: (@escaping ([String: AnyObject]) -> Void)) {
        socket.on("newChatMessage") { (dataArray, ack) in
            var msgDictionary = [String:AnyObject]()
            msgDictionary["nickname"] = dataArray[0] as! String as AnyObject
            msgDictionary["message"] = dataArray[1] as! String as AnyObject
            msgDictionary["date"] = dataArray[2] as! String as AnyObject
            
            completHandler(msgDictionary)
        }
    }
    
    func sendStartTypingMessage(nickName: String){
        socket.emit("startType", nickName)
    }
        
    func sendStopTypingMessage(nickName:String){
        socket.emit("stopType", nickName)
    }
}
