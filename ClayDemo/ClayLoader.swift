//
//  ClayLoader.swift
//  test
//
//  Created by Vlad Tufis on 01/06/15.
//  Copyright (c) 2015 Vlad Tufis. All rights reserved.
//

import UIKit

class ClayLoader: UIView {
    // the name of the notification dispatched when this view's animation has anded
    static let ANIMATION_ENDED = "ANIMATION_ENDED"
    
    // the layer containing the loader bar
    private var loaderLayer: CAShapeLayer!
    
    // the animation property of this view
    private var animation: CABasicAnimation!
    
    // the number of times this
    var animationRepeatCount: Float = Float.infinity
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
        
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0,
            y: frame.size.height / 2.0),
            radius: (frame.size.width - 10)/2,
            startAngle: 0.0,
            endAngle: CGFloat(M_PI / 4),
            clockwise: true)
        
        // Setup the CAShapeLayer with the path, colors, and line width
        loaderLayer = CAShapeLayer()
        loaderLayer.path = circlePath.CGPath
        loaderLayer.fillColor = UIColor.clearColor().CGColor
        loaderLayer.strokeColor = UIColor(red: 0.227, green: 0.619, blue: 0.137, alpha: 1.0).CGColor
        loaderLayer.lineCap = kCALineCapRound
        loaderLayer.lineWidth = 15.0;
        
        // Don't draw the circle initially
        loaderLayer.strokeEnd = 0.0
        
        // Add the loaderLayer to the view's layer's sublayers
        layer.addSublayer(loaderLayer)
    }
    
    // stop the current animations and reconfigure this view's animation
    func animate() {
        self.stopAnimation()
        self.configureAnimation()
    }
    
    // remove all animations from this view's layer
    func stopAnimation() {
        self.layer.removeAllAnimations()
    }
    
    private func configureAnimation() {
        loaderLayer.strokeEnd = 1.0
        // configure the animation parameters
        animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.repeatCount = self.animationRepeatCount
        animation.duration = 1.5
        animation.fromValue = 0
        animation.delegate = self
        animation.toValue = CGFloat(M_PI * 2.0)
        // add the animation to the view's layer
        self.layer.addAnimation(animation, forKey: "loader")
    }
    
    // override this callback and dispatch an ANIMATION_ENDED notification to be picked up by whoever registered  to it
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        loaderLayer.strokeEnd = 0.0
        NSNotificationCenter.defaultCenter().postNotificationName(ClayLoader.ANIMATION_ENDED, object: nil, userInfo: nil)
    }
}
