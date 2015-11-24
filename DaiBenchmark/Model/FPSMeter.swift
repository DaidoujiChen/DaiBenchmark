//
//  FPSMeter.swift
//  DaiBenchmark
//
//  Created by DaidoujiChen on 2015/11/23.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

import Foundation
import UIKit

// MARK: Notification
extension FPSMeter {
    
    // 當 app 回來時的動作
    @objc private func applicationDidBecomeActiveNotification() {
        guard let safeDisplayLink = self.displayLink else {
            return
        }
        safeDisplayLink.paused = false
        self.nextDeltaTimeZero = true
    }
    
    // 當 app 離開時的動作
    @objc private func applicationWillResignActiveNotification() {
        guard let safeDisplayLink = self.displayLink else {
            return
        }
        safeDisplayLink.paused = true
        self.nextDeltaTimeZero = true
    }
    
}

// MARK: Private Instance Method
extension FPSMeter {
    
    // CADisplayLink 回調
    @objc private func displayLinkUpdated() {
        guard let safeDisplayLink = self.displayLink else {
            return
        }
        
        let currentTimestamp = safeDisplayLink.timestamp
        var deltaTime: CFTimeInterval
        if self.nextDeltaTimeZero {
            self.nextDeltaTimeZero = false
            deltaTime = 0
        }
        else {
            deltaTime = currentTimestamp - self.previousTimestamp
        }
        self.previousTimestamp = currentTimestamp
        
        if self.framePerSeconds.count > 100 {
            self.framePerSeconds.removeFirst()
        }
        let framePerSecond = 1.0 / deltaTime
        self.framePerSeconds.append(framePerSecond)
        self.delegate?.onUpdate(framePerSecond, avg: self.avg())
    }
    
    // 計算平均
    private func avg() -> CFTimeInterval {
        var avg: CFTimeInterval = 0
        for fps in self.framePerSeconds {
            avg += fps
        }
        avg /= Double(self.framePerSeconds.count)
        return avg
    }
    
    // 加入 CADisplayLink
    private func addDisplayLink() {
        let newDisplayLink = CADisplayLink(target: self, selector: "displayLinkUpdated")
        newDisplayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        self.displayLink = newDisplayLink
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActiveNotification", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActiveNotification", name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    // 移除 CADisplayLink
    private func removeDisplayLink() {
        guard let safeDisplayLink = self.displayLink else {
            return
        }
        safeDisplayLink.invalidate()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
}

// MARK: FPSMeter
class FPSMeter {
    
    // 回調
    var delegate: FPSMeterDelegate?
    
    // 監測 FPS 相關
    var displayLink: CADisplayLink?
    var nextDeltaTimeZero = true
    var previousTimestamp: CFTimeInterval = 0
    var framePerSeconds: [CFTimeInterval] = []
    
    init(delegate: FPSMeterDelegate) {
        self.addDisplayLink()
        self.delegate = delegate
    }
    
    deinit {
        self.removeDisplayLink()
    }
    
}

// MARK: FPSMeterDelegate
protocol FPSMeterDelegate {
    
    func onUpdate(fps: CFTimeInterval, avg: CFTimeInterval)
    
}
