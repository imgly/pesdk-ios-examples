//
//  NSTimerExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

// Taken from https://github.com/radex/SwiftyTimer

private class NSTimerActor {
    var block: () -> ()

    init(_ block: () -> ()) {
        self.block = block
    }

    @objc func fire() {
        block()
    }
}

extension NSTimer {
    class func new(after interval: NSTimeInterval, _ block: () -> ()) -> NSTimer {
        return new(after: interval, repeats: false, block)
    }

    class func new(after interval: NSTimeInterval, repeats: Bool, _ block: () -> ()) -> NSTimer {
        let actor = NSTimerActor(block)
        return self.init(timeInterval: interval, target: actor, selector: "fire", userInfo: nil, repeats: repeats)
    }

    class func after(interval: NSTimeInterval, _ block: () -> ()) -> NSTimer {
        let timer = NSTimer.new(after: interval, block)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        return timer
    }

    class func after(interval: NSTimeInterval, repeats: Bool, _ block: () -> ()) -> NSTimer {
        let timer = NSTimer.new(after: interval, repeats: repeats, block)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        return timer
    }
}
