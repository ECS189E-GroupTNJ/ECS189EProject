//
//  NearbyMessageModel.swift
//  nearbymessagemodel
//
//  Created by Jason 반 on 12/1/18.
//  Copyright © 2018 Jason 반. All rights reserved.
//

import Foundation
import CoreBluetooth
import UserNotifications

class NearbyMessageModel{

    var nearbyPermission: GNSPermission?
    var messageManager = GNSMessageManager(apiKey: "AIzaSyCcgDrcE6R4Hka4F1INzKEQBnyhBmfRo5Y", paramsBlock: { (params: GNSMessageManagerParams?) in
        guard let params = params else { print("Message manager error"); return }
        params.bluetoothPowerErrorHandler = { (hasError: Bool) in
            // Update the UI for Bluetooth power
            print("Bluetooth not turned on")
        }
        params.bluetoothPermissionErrorHandler = { (hasError: Bool) in
            // Update the UI for Bluetooth permission
            print("Bluetooth permission not granted")
        }
    })
    var publication: GNSPublication?
    var subscription: GNSSubscription?
    
    var messages = [String]()
    
    func bluetoothAvailable(_ central: CBCentralManager) -> Bool {
        if central.state == .poweredOff{
            print("Bluetooth switched off or not initialized")
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
    
    func shareMessage(with trackID: String) {
        let text = "\(Storage.displayName)\n\(trackID)"
        if let messageManager = self.messageManager{
            GNSMessageManager.setDebugLoggingEnabled(true)
            let message: GNSMessage = GNSMessage(content: text.data(using: .utf8, allowLossyConversion: true))
            publication = messageManager.publication(with: message,
                paramsBlock: { (params: GNSPublicationParams?) in
                    guard let params = params else { return }
                    params.strategy = GNSStrategy(paramsBlock: { (params: GNSStrategyParams?) in
                        guard let params = params else { return }
                        params.discoveryMediums = .BLE
                })
            })
        }
    }
    
    func toggleSendNotification() {
        Storage.sendNotification = !Storage.sendNotification
    }
    
    func toggleReceiveNotification(callback: @escaping (_ message: GNSMessage) -> Void) {
        Storage.receiveNotification = !Storage.receiveNotification
        if Storage.receiveNotification {
            if let messageManager = self.messageManager{
                subscription =
                    messageManager.subscription(messageFoundHandler: { (message: GNSMessage?) in
                        guard let realMessage = message else {
                            print("Message not received?")
                            return
                        }
                        DispatchQueue.main.async { callback(realMessage) }
                    },
                    messageLostHandler: { (message: GNSMessage?) in
                        print("Message no longer received")
                        
                    },
                    paramsBlock:{ (params: GNSSubscriptionParams?) in
                        guard let params = params else { return }
                        params.strategy = GNSStrategy(paramsBlock: { (params: GNSStrategyParams?) in
                            guard let params = params else { return }
                            params.allowInBackground = true
                            params.discoveryMediums = .BLE
                    })
                })
            }
        }
    }
    
//    func grantPermission(){
//        GNSPermission.setGranted(!GNSPermission.isGranted())
//    }
    }
