//
//  BallView.swift
//  DaiBenchmark
//
//  Created by DaidoujiChen on 2015/11/23.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

import UIKit

// MARK: BallView
class BallView: UIView {
    
    let colors = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.blackColor()]
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Ellipse
    }
    
    convenience init(point: CGPoint) {
        let radius = CGFloat((arc4random() % 60)) / 10.0 + 1.0
        let xCenter = point.x - radius
        let yCenter = point.y - radius
        self.init(frame: CGRect(x: xCenter, y: yCenter, width: radius * 2, height: radius * 2))
        let index = Int(arc4random() % UInt32(self.colors.count))
        self.backgroundColor = self.colors[index]
        let alpha = CGFloat(arc4random() % 50) / 100 + 0.5
        self.alpha = alpha
        self.layer.cornerRadius = radius;
        self.layer.masksToBounds = true;
    }
    
}
