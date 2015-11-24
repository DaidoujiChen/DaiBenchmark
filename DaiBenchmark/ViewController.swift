//
//  ViewController.swift
//  DaiBenchmark
//
//  Created by DaidoujiChen on 2015/11/23.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

import UIKit
import CoreMotion

// MARK: FPSMeterDelegate
extension ViewController: FPSMeterDelegate {
    
    func onUpdate(fps: CFTimeInterval, avg: CFTimeInterval) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
            guard let safeSelf = self else {
                return
            }
            safeSelf.currentFPS = fps
            let currentBalls = safeSelf.view.subviews.count - 3
            if currentBalls > safeSelf.maxBalls {
                safeSelf.maxBalls = currentBalls
            }
            safeSelf.informationLabel.text = String(format: "FPS: %.0f, avgFPS: %.0f Balls: %d, Max: %d", fps, avg, currentBalls, safeSelf.maxBalls)
            safeSelf.view.bringSubviewToFront(safeSelf.informationLabel)
        }
    }
    
}

// MARK: UICollisionBehaviorDelegate
extension ViewController: UICollisionBehaviorDelegate {
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        if self.currentFPS >= 59.0 {
            dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
                guard let safeSelf = self else {
                    return
                }
                let currentDate = NSDate.timeIntervalSinceReferenceDate()
                if (currentDate - safeSelf.prevDate) > 0.5 {
                    safeSelf.addNewBallFrom()
                    safeSelf.prevDate = currentDate
                }
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        guard let view = item as? BallView else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
            guard let safeSelf = self else {
                return
            }
            if safeSelf.currentFPS <= 55.0 {
                safeSelf.removeBallFrom(view)
            }
        }
    }
    
}

// MARK: Private Instance Method
extension ViewController {
    
    private func dynamicItemBehavior() -> UIDynamicItemBehavior {
        let newDynamicItem = UIDynamicItemBehavior()
        newDynamicItem.elasticity = CGFloat(arc4random() % UInt32(20)) / 100.0 + 0.8
        newDynamicItem.friction = CGFloat(arc4random() % UInt32(5))
        newDynamicItem.density = CGFloat(arc4random() % UInt32(5))
        newDynamicItem.resistance = CGFloat(arc4random() % UInt32(5))
        newDynamicItem.angularResistance = CGFloat(arc4random() % UInt32(5))
        return newDynamicItem
    }
    
    // 新增一顆球
    private func addNewBallFrom() {
        let newPoint = CGPoint(x: CGFloat(arc4random()) % CGRectGetWidth(self.view.bounds), y: 20.0)
        let newBallView = BallView(point: newPoint)
        self.view.addSubview(newBallView)
        self.gravity.addItem(newBallView)
        self.collision.addItem(newBallView)
        self.dynamicItem.addItem(newBallView)
    }
    
    // 移除一顆球
    private func removeBallFrom(view: UIView) {
        self.gravity.removeItem(view)
        self.collision.removeItem(view)
        self.dynamicItem.removeItem(view)
        view.removeFromSuperview()
        
    }
    
    // 初始化陀螺儀監測
    private func setupAccelerometer() {
        self.motionManager.accelerometerUpdateInterval = 0.05
        self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) { [weak self] (accelerometerData, error) -> Void in
            guard
                let safeSelf = self,
                let safeAccelerometerData = accelerometerData
                else {
                    return
            }
            safeSelf.gravity.gravityDirection = CGVector(dx: safeAccelerometerData.acceleration.x, dy: 1.0)
        }
    }
    
    // 初始化動態物件
    private func setupDynamicAnimator() {
        let newAnimator = UIDynamicAnimator(referenceView: self.view)
        newAnimator.addBehavior(self.gravity)
        newAnimator.addBehavior(self.collision)
        self.collision.translatesReferenceBoundsIntoBoundary = true
        self.collision.collisionDelegate = self
        newAnimator.addBehavior(self.dynamicItem)
        self.dynamicItem.elasticity = 0.95
        self.animator = newAnimator
    }
    
}

// MARK: ViewController
class ViewController: UIViewController {
    
    @IBOutlet weak var informationLabel: UILabel!
    
    // 動態相關
    var animator: UIDynamicAnimator?
    let gravity = UIGravityBehavior()
    let collision = UICollisionBehavior()
    let dynamicItem = UIDynamicItemBehavior()
    
    // FPS 顯示與紀錄
    var meter: FPSMeter?
    var currentFPS: CFTimeInterval?
    
    // 記錄畫面上球的數量, 並且用時間限制不可以一次太多球
    var maxBalls: Int = 0
    var prevDate = NSDate.timeIntervalSinceReferenceDate()
    
    // 利用陀螺儀改變球移動方向
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.meter = FPSMeter(delegate: self)
        self.setupDynamicAnimator()
        self.setupAccelerometer()
    }
    
    override func viewDidAppear(animated: Bool) {
        for _ in 0..<20 {
            self.addNewBallFrom()
        }
    }
    
}

