//
//  AddSongVC.swift
//  Project
//
//  Created by Noshin Kamal on 11/26/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import UIKit
import SnapKit
import LiquidFloatingActionButton
import UserNotifications

public class CustomCell : LiquidFloatingCell {
    var name: String = "sample"
    
    init(icon: UIImage, name: String) {
        self.name = name
        super.init(icon: icon)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setupView(_ view: UIView) {
        super.setupView(view)
        let label = UILabel()
        label.text = name
        label.textColor = UIColor.white
        label.font = UIFont(name: "Helvetica-Neue", size: 12)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(self).offset(-155)
            make.width.equalTo(180)
            make.top.height.equalTo(self)
        }
    }
}


class AddSongVC: UIViewController, LiquidFloatingActionButtonDelegate, LiquidFloatingActionButtonDataSource, UNUserNotificationCenterDelegate {
    func numberOfCells(_ liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return settingCells.count
    }
    
    func cellForIndex(_ index: Int) -> LiquidFloatingCell {
        return settingCells[index]
    }
    
    public class CustomDrawingActionButton: LiquidFloatingActionButton {
        
        override public func createPlusLayer(_ frame: CGRect) -> CAShapeLayer {
            
            let plusLayer = CAShapeLayer()
            plusLayer.lineCap = CAShapeLayerLineCap.round
            plusLayer.strokeColor = UIColor.white.cgColor
            plusLayer.lineWidth = 3.0
            
            let w = frame.width
            let h = frame.height
            
            let points = [
                (CGPoint(x: w * 0.25, y: h * 0.35), CGPoint(x: w * 0.75, y: h * 0.35)),
                (CGPoint(x: w * 0.25, y: h * 0.5), CGPoint(x: w * 0.75, y: h * 0.5)),
                (CGPoint(x: w * 0.25, y: h * 0.65), CGPoint(x: w * 0.75, y: h * 0.65))
            ]
            
            let path = UIBezierPath()
            for (start, end) in points {
                path.move(to: start)
                path.addLine(to: end)
            }
            
            plusLayer.path = path.cgPath
            
            return plusLayer
        }
    }

    @IBOutlet weak var captureButton: UIButton!
    
    var userModel = SpotifyUserModel(forTheFirstTime: true)
    var messageModel = NearbyMessageModel()
    var addedTrackID: String?
    var addedTrackInfo: SpotifyUserModel.TrackInfo?
    
    var settingsButton: LiquidFloatingActionButton!
    var settingCells: [LiquidFloatingCell] = []
    
    
    @IBOutlet var roundButtons: [RoundButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureButton.layer.cornerRadius = captureButton.frame.height / 2
        captureButton.setTitleColor(UIColor.white, for: .normal)
        captureButton.layer.shadowColor = UIColor.red.cgColor
        captureButton.layer.shadowRadius = 50
        captureButton.layer.shadowOpacity = 0.5
        captureButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        captureButton.titleLabel?.adjustsFontSizeToFitWidth = true
        captureButton.titleLabel?.minimumScaleFactor = 0.5
        
        UNUserNotificationCenter.current().delegate = self
        
        for roundButton in roundButtons {
            roundButton.cornerRadius = roundButton.frame.height / 2
            print(roundButton.cornerRadius, roundButton.frame.height)
        }
        
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = CustomDrawingActionButton(frame: frame)
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            return floatingActionButton
        }

        let floatingFrame = CGRect(x: self.view.frame.width - 56 - 16, y: self.view.frame.height - 56 - 16, width: 56, height: 56)
        settingsButton = createButton(floatingFrame, .up)
        
        settingCells.append(CustomCell(icon: UIImage(named: "playlist")!, name: "select playlist"))
        settingCells.append(CustomCell(icon: UIImage(named: "smart")!, name: "smart selection"))
        settingCells.append(CustomCell(icon: UIImage(named: "peer")!, name: "receive notification"))
        settingCells.append(CustomCell(icon: UIImage(named: "peer")!, name: "send notification"))
        
        settingCells[1].imageView.tintColor = Storage.useSmartSelection ? UIColor(red: 147 / 255, green: 235 / 255, blue: 101 / 255, alpha: 1.0) : UIColor.white
        settingCells[2].imageView.tintColor = Storage.receiveNotification ? UIColor(red: 147 / 255, green: 235 / 255, blue: 101 / 255, alpha: 1.0) : UIColor.white
        settingCells[3].imageView.tintColor = Storage.sendNotification ? UIColor(red: 147 / 255, green: 235 / 255, blue: 101 / 255, alpha: 1.0) : UIColor.white
        
        self.view.addSubview(settingsButton)
    }
    
    func liquidFloatingActionButton(_ liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        liquidFloatingActionButton.close()
        switch index {
        case 0:
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "playlistVC") as! PlaylistVC
            viewController.userModel = userModel
            self.navigationController?.pushViewController(viewController, animated: true)
        case 1:
            if !Storage.useSmartSelection {
                settingCells[1].imageView.tintColor = UIColor(red: 147 / 255, green: 235 / 255, blue: 101 / 255, alpha: 1.0)
                Storage.useSmartSelection = true
            }
            else {
                settingCells[1].imageView.tintColor = UIColor.white
                Storage.useSmartSelection = false
            }
        case 2:
            if !Storage.receiveNotification {
                settingCells[2].imageView.tintColor = UIColor(red: 147 / 255, green: 235 / 255, blue: 101 / 255, alpha: 1.0)
                messageModel.toggleReceiveNotification { (message) in
                    self.handleMessageNotification(message: message)
                }
            }
            else {
                settingCells[2].imageView.tintColor = UIColor.white
                messageModel.toggleReceiveNotification(callback: { (_) in })
            }
        case 3:
            if !Storage.sendNotification {
                settingCells[3].imageView.tintColor = UIColor(red: 147 / 255, green: 235 / 255, blue: 101 / 255, alpha: 1.0)
                messageModel.toggleSendNotification()
            }
            else {
                settingCells[3].imageView.tintColor = UIColor.white
                messageModel.toggleSendNotification()
            }
        default: ()
        }
    }
    
    func handleMessageNotification(message: GNSMessage) {
        if UIApplication.shared.applicationState != .active {
            
            guard let text = String(data: message.content, encoding: .utf8) else {
                print("Could not receive message")
                return
            }
            
            let sender = String(text.split(separator: "\n")[0])
            let trackID = String(text.split(separator: "\n")[1])
            
            let trackInfo = userModel.getTrackInfo(track: trackID)
            addedTrackID = trackID
            addedTrackInfo = trackInfo
            
            let content = UNMutableNotificationContent()
            content.title = "DriverSpotify"
            content.subtitle = "\(sender) added a song:"
            content.body = "\(trackInfo.trackName)\n\(trackInfo.artistName)"
            content.categoryIdentifier = "com.ecs189e.driverspotify.notification.category"
            var albumImage: UIImage
            
            if let image = trackInfo.albumImage {
                albumImage = UIImage(ciImage: image)
            }
            else {
                albumImage = UIImage(named: "defaultCover")!
            }
            
            if let attachment = UNNotificationAttachment.create(identifier: ProcessInfo.processInfo.globallyUniqueString, image: albumImage, options: nil) {
                content.attachments = [attachment]
            }
            
            let action = UNNotificationAction(identifier: "add", title: "Add", options: [.foreground])
            let category = UNNotificationCategory(identifier: "com.ecs189e.driverspotify.notification.category", actions: [action], intentIdentifiers: [], options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            let request = UNNotificationRequest(identifier: "addSongRequest", content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                print("\(error?.localizedDescription ?? "")")
            }
        }
        else {
            // popup for query
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let trackID = addedTrackID else {
            print("Track disappeared?")
            return
        }
        
        if response.actionIdentifier == "add" {
            userModel.addTrackToPlaylist(track: trackID)
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // display for popup thing
        
        completionHandler([])
    }
    
    
    
    
    @IBAction func capturePressed() {
        userModel.addCurrentTrackToPlaylist()
        // send notification
    }
    

}

extension UNNotificationAttachment {
    
    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            guard let imageData = image.pngData() else {
                return nil
            }
            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}
