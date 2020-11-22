//
//  Message.swift
//  ChatWith
//
//  Created by 赤堀雅司 on 29/9/20.
//

import UIKit
import Firebase
import FirebaseAuth

class Message: NSObject {
  var fromId: String?
  var text: String?
  var timestamp: NSNumber?
  var toId: String?
  
  var imageUrl: String?
  var videoUrl: String?
  var imageWidth: NSNumber?
  var imageHeight: NSNumber?
  
  init(dictionary: [String: Any]) {
    self.fromId = dictionary["fromId"] as? String
    self.text = dictionary["text"] as? String
    self.timestamp = dictionary["timestamp"] as? NSNumber
    self.toId = dictionary["toId"] as? String
    
    self.imageUrl = dictionary["imageUrl"] as? String
    self.videoUrl = dictionary["videoUrl"] as? String
    self.imageWidth = dictionary["imageWidth"] as? NSNumber
    self.imageHeight = dictionary["imageHeight"] as? NSNumber
    
    
  }
  
  func chatPartnerId() -> String? {
   
    return fromId == Auth.auth().currentUser?.uid ? toId: fromId
    //if true, return toId, and if false, return fromId
    //if fromId = currentUsers uid -> return toId
    //もし、メッセージの送り主がユーザーと一致した時、toIdを返す
  }
}
