//
//  NearbyMessageModel.swift
//  nearbymessagemodel
//
//  Created by Jason 반 on 12/1/18.
//  Copyright © 2018 Jason 반. All rights reserved.
//

import Foundation
import CoreBluetooth

class NearbyMessageModel{

    var nearbyPermission: GNSPermission?
    var messageManager = GNSMessageManager(apiKey: "ourAPIKey")
    var publication: GNSPublication?
    var subscription: GNSSubscription?
    
    var messages = [String]()
    
    func bluetoothAvailable(_ central: CBCentralManager){
        if central.state == .poweredOff{
            Print("Bluetooth switched off or not initialized")
            return false
        }else{
            switch CBPeripheralManager.authorizationStatus(){
            case .authorized:
                print("Bluetooth authorized")
                return true
            case .denied:
                print("Bluetooth not authorized")
                return false
            case .notDetermined:
                print("not determined")
                return false
            default:
                return true
            }
        }
    }
    
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
