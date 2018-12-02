//
//  NearbyMessageModel.swift
//  nearbymessagemodel
//
//  Created by Jason 반 on 12/1/18.
//  Copyright © 2018 Jason 반. All rights reserved.
//

import Foundation
class NearbyMessageModel{

    var nearbyPermission: GNSPermission?
    var messageManager = GNSMessageManager(apiKey: "AIzaSyBohnv6pY_vypGpIV8osHPc6jL6GB3gjmA")
    var publication: GNSPublication?
    var subscription: GNSSubscription?
    
    //AIzaSyBohnv6pY_vypGpIV8osHPc6jL6GB3gjmA
    var messages = [String]()
    
    func shareMessage(withName name: String) {
        
        if let messageManager = self.messageManager{
            messageManager.setDebugLoggingEnabled(true)
            let message: GNSMessage = GNSMessage(content: name.data(using: .utf8, allowLossyConversion: true))
            publication = messageManager.publication(with: message)
        }
    }
    
//    func receiveMessage(){
//        if let messageManager = self.messageManager{
 //           subscription =
 //       }
    
    func stopNearbyMessaging(){
        publication = nil
        subscription = nil
    }
    
//    func grantPermission(){
//        GNSPermission.setGranted(!GNSPermission.isGranted())
//    }
    }
