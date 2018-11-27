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


class AddSongVC: UIViewController, LiquidFloatingActionButtonDelegate, LiquidFloatingActionButtonDataSource {
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
    
    var settingsButton: LiquidFloatingActionButton!
    var settingCells: [LiquidFloatingCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureButton.layer.cornerRadius = captureButton.frame.height / 2
        captureButton.setTitleColor(UIColor.white, for: .normal)
        captureButton.layer.shadowColor = UIColor.red.cgColor
        captureButton.layer.shadowRadius = 50
        captureButton.layer.shadowOpacity = 0.5
        captureButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
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
        settingCells.append(CustomCell(icon: UIImage(named: "peer")!, name: "receive notification"))
        settingCells.append(CustomCell(icon: UIImage(named: "peer")!, name: "send notification"))
        
        
        self.view.addSubview(settingsButton)
    }
    
    func liquidFloatingActionButton(_ liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        liquidFloatingActionButton.close()
        switch index {
        case 0:
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "playlistVC")
            self.navigationController?.pushViewController(viewController, animated: true)
        case 1: ()
        case 2: ()
        default: ()
        }
    }

}
