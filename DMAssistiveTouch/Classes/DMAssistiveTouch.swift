//
//  DMAssistiveTouch.swift
//
//  Created by Bean on 15/8/24.
//  Copyright (c) 2015年 BeanDu. All rights reserved.
//

import UIKit

protocol DMAssistiveTouchDelegate{
    func assistiveTouchViewTapAction(assistiveTouchView:DMAssistiveTouch)
}

let EdgeDistance:CGFloat = 5.0

class DMAssistiveTouch: UIImageView {
    var viewCtrl:UIViewController?
    var centerDistance:CGPoint = CGPoint.zero
    var startCenterPoint:CGPoint = CGPoint.zero
   internal var delegate:DMAssistiveTouchDelegate?
    var timer:Timer?
    var isAppear:Bool = true
    
    //上次frame
    var lastFrame:CGRect! = CGRect(x:100,y:100,width:72,height:72)
    class var sharedInstance:DMAssistiveTouch {
        struct Singleton {
            static let instance = DMAssistiveTouch(frame: CGRect(x:100,y:100,width:72,height:72))
        }
        return Singleton.instance
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureAction(panGesture:)))
        self.addGestureRecognizer(panGesture)
        
        let tapGestrue = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureAction(tapGesture:)))
        self.addGestureRecognizer(tapGestrue)
        self.backgroundColor = UIColor.orange
//        self.image = UIImage(named: "")
//        self.animationImages =
//        self.layer.cornerRadius = CGRectGetWidth(frame)/2.0
//        self.clipsToBounds = true
//        self.layer.shadowColor = UIColor.blackColor().CGColor
//        self.layer.shadowOffset = CGSizeMake(1, 1)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    class func showInViewController(viewController:UIViewController){
        if let _ = DMAssistiveTouch.sharedInstance.superview{
            
        }else{
            if let view = viewController.view {
                view.addSubview(DMAssistiveTouch.sharedInstance)
            }else if let window = UIApplication.shared.keyWindow{
                window.addSubview(DMAssistiveTouch.sharedInstance)
            }
        }
        DMAssistiveTouch.disableAction()
        if DMAssistiveTouch.sharedInstance.frame.equalTo(CGRect(x:100,y:100,width:72,height:72)){
            DMAssistiveTouch.sharedInstance.center = CGPoint(x:DMAssistiveTouch.sharedInstance.superview!.frame.width-DMAssistiveTouch.sharedInstance.bounds.width/2.0, y:DMAssistiveTouch.sharedInstance.superview!.frame.height-DMAssistiveTouch.sharedInstance.bounds.height/2.0)
        }
    }

    // : MARK
    func tapGestureAction(tapGesture:UITapGestureRecognizer){
        self.delegate?.assistiveTouchViewTapAction(assistiveTouchView: self)
    }
    func panGestureAction(panGesture:UIPanGestureRecognizer){
        
        let point = panGesture.location(in: UIApplication.shared.keyWindow!)
        if UIGestureRecognizerState.began == panGesture.state{
            //获取点击位置与中心点在x,y方向上的距离
            self.centerDistance = CGPoint(x:point.x-self.center.x,y: point.y-self.center.y)
            self.startCenterPoint = self.center
        }else if UIGestureRecognizerState.changed == panGesture.state{
            let tempPoint = self.constraintAssistiveTouchViewWithPoint(point: point)
            self.center = CGPoint(x:tempPoint.x-self.centerDistance.x, y:tempPoint.y-self.centerDistance.y)
            
        }else if UIGestureRecognizerState.ended == panGesture.state{
            let tempPoint = self.constraintAssistiveTouchViewWithPoint(point: point)
            self.endPointFromPoint(point: CGPoint(x:tempPoint.x-self.centerDistance.x, y:tempPoint.y-self.centerDistance.y))
        }else if UIGestureRecognizerState.cancelled == panGesture.state{
            let tempPoint = self.constraintAssistiveTouchViewWithPoint(point: point)
            self.endPointFromPoint(point: CGPoint(x:tempPoint.x-self.centerDistance.x, y:tempPoint.y-self.centerDistance.y))
        }
    }
    //约束AssistiveTouchView在屏幕之内
    func constraintAssistiveTouchViewWithPoint(point:CGPoint)->CGPoint{
        var tempPoint = point
//        let minX = self.bounds.width/2.0+EdgeDistance
//        let maxX = self.superview!.bounds.width-self.bounds.width/2.0-EdgeDistance
        let centerFrame = CGRect(x:0,y:0,width:self.superview!.bounds.width, height:self.superview!.bounds.height)
        if tempPoint.x < centerFrame.minX{
            tempPoint = CGPoint(x:centerFrame.minX,y:point.y)
        }else if tempPoint.x > centerFrame.maxX{
            tempPoint = CGPoint(x:centerFrame.maxX,y: point.y)
        }
        if tempPoint.x < centerFrame.minY{
            tempPoint = CGPoint(x:point.x, y:centerFrame.minY)
        }else if tempPoint.x > centerFrame.maxY{
            tempPoint = CGPoint(x:point.x, y:centerFrame.maxY)
        }
        return tempPoint
    }
    //实现"靠边滑动"效果
    func endPointFromPoint(point:CGPoint){
        var tempPoint = point
        let centerFrame = CGRect(x:self.bounds.width/2.0+EdgeDistance,y: self.bounds.height/2.0+EdgeDistance,width: self.superview!.bounds.width-self.bounds.width-2*EdgeDistance,height: self.superview!.bounds.height-self.bounds.height-2*EdgeDistance)
        let leftSpace:CGFloat = point.x - (centerFrame.minX)
        let rightSpace:CGFloat = (centerFrame.maxX) - point.x
        let topSpace:CGFloat = point.y - (centerFrame.minY)
        let bottemSpace:CGFloat = (centerFrame.maxY) - point.y
        var distance:CGFloat = leftSpace
        if (leftSpace - rightSpace) <= 0 {
            tempPoint = CGPoint(x:centerFrame.minX, y:point.y)
        }else{
            distance = rightSpace
            tempPoint = CGPoint(x:centerFrame.maxX, y:point.y)
        }
        if bottemSpace < 50 {
            tempPoint = CGPoint(x:point.x, y:(centerFrame.maxY))
        }
        if topSpace < 50 {
            tempPoint = CGPoint(x:point.x, y:(centerFrame.minY))
        }
        if leftSpace < 0 {
            tempPoint = CGPoint(x:(centerFrame.minX), y:tempPoint.y)
        }
        if rightSpace < 0 {
            tempPoint = CGPoint(x:(centerFrame.maxX), y:tempPoint.y)
        }
        
        UIView.animate(withDuration: Double(distance/100.0), delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            ()->Void in
            self.center = tempPoint
            self.transform = CGAffineTransform.identity
            }, completion: {
                (isFinished:Bool)->Void in
                
        })
    }
    
    // MARK: -出现与消失
    
    class func didAppear(animation:Bool){
        if DMAssistiveTouch.sharedInstance.isAppear == true{
            return
        }
        DMAssistiveTouch.sharedInstance.isAppear = true
        UIView.animate(withDuration: 0.3, animations: {
            ()->Void in
            DMAssistiveTouch.sharedInstance.alpha = 1.0
        })
    }
    class func didAppear(animation:Bool, delay:Bool){
        if DMAssistiveTouch.sharedInstance.isAppear == true{
            return
        }
        UIView.animate(withDuration: 0.3, delay: 2, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            ()->Void in
            DMAssistiveTouch.sharedInstance.alpha = 1.0
            }, completion: {
                (isFinished:Bool)->Void in
                DMAssistiveTouch.sharedInstance.isAppear = true
        })
    }
    class func didDisappear(animation:Bool){
        if DMAssistiveTouch.sharedInstance.isAppear == false{
            return
        }
        DMAssistiveTouch.sharedInstance.isAppear = false
        DMAssistiveTouch.sharedInstance.lastFrame = DMAssistiveTouch.sharedInstance.frame
        UIView.animate(withDuration: 0.3, animations: {
            ()->Void in
            DMAssistiveTouch.sharedInstance.alpha = 0.0
        })
    }
    
    class func disableAction(){
        if let temp = DMAssistiveTouch.sharedInstance.timer {
            DMAssistiveTouch.sharedInstance.timer?.invalidate()
            DMAssistiveTouch.sharedInstance.timer = nil
        }
    }
    class func dismiss(){
        DMAssistiveTouch.disableAction()
        DMAssistiveTouch.sharedInstance.removeFromSuperview()
    }
    func displayAnimation(){
        self.startAnimating()
    }
    
    // MARK:  -
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        NSLog("%@", NSStringFromCGPoint(point))
        if self.alpha > 0.5 {
            if self.bounds.contains(point){
                return self
            }
        }
        return super.hitTest(point, with: event)
    }

}
