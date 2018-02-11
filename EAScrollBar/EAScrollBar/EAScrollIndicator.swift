//
//  EAScrollView+Indicator.swift
//  Edit
//
//  Created by Ehud Adler on 1/29/18.
//  Copyright © 2018 Ehud Adler. All rights reserved.
//

import UIKit

/********** Delegate ****************/
public protocol EAScrollDelegate {
  func sectionPercent(percent: CGFloat)
}
/********** End delegate ****************/

public class EAScrollIndicator : NSObject
{
  /**** Private *********************************************/
  fileprivate var indicatorBackground                = EAIndicatorBackground()  // Hosting EAIndicatorBackground
  fileprivate var titleView                          = EAScrollTitleView()
  fileprivate var previousScrollViewYOffset: CGFloat = 0.0
  fileprivate var delegate                           : EAScrollDelegate?
  fileprivate weak var titleTimer                    : Timer?
  fileprivate var showedThisSection                  : Bool?

  /**** Public private(set) *********************************/
  public fileprivate(set) weak var scrollView : UIScrollView?
  public fileprivate(set) var points          : [EAIndicatorPoint]?
  
  public override init() { super.init() }
  
  public init(scrollView: UIScrollView, points: [EAIndicatorPoint]?)
  {
    super.init()
    
    self.showedThisSection                        = false
    self.scrollView                               = scrollView
    self.points                                   = points
    
    self.points?.sort {$0.location < $1.location}
    
    self.scrollView?.showsVerticalScrollIndicator = false
    
    self.setUpBackground()
    self.scrollViewObserver()
    
  }
  
  public func flush()
  {
    NotificationCenter.default.removeObserver(self)
    if let activeScrollView = self.scrollView { activeScrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset)) }
  }
  
  
  override public func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?)
  {
    if keyPath == #keyPath(UIScrollView.contentOffset)
    {
      
      
      if let yPos = (object as? UIScrollView)?.contentOffset.y
      {
        
        var percent     : CGFloat = 0.0
        previousScrollViewYOffset = yPos
        if let index = self.points?.index(where: { $0.location > yPos })
        {
          if let pointSet = self.points
          {
            
            var rightPos :CGFloat  = 0.0
            var leftPos  :CGFloat  = 0.0
            
            if (index - 1 < 0)
            { leftPos = 0.0 } else
            { leftPos = pointSet[index - 1].location }
            
            if (index > (self.points?.count)!)
            { rightPos =  (self.scrollView?.contentSize.height)!
              - (self.scrollView?.bounds.height)!
              + (self.scrollView?.contentInset.bottom)!} else
            { rightPos = pointSet[index].location }
          
            let difference         = rightPos - leftPos                                      // Full Difference
            let differenceFromPred = yPos - leftPos                                          // Difference from pred
            percent                = CGFloat(differenceFromPred * 100 / difference)          // Percent
            
            delegate?.sectionPercent(percent: percent)
            
            if percent < 20
            {

              if titleTimer == nil && !showedThisSection!
              {
                showedThisSection = true
                titleView.setTitle(title: self.points![index].title)
                titleTimer = Timer.scheduledTimer(timeInterval: 1,
                                                  target: self,
                                                  selector: #selector(timerFired),
                                                  userInfo: nil,
                                                  repeats: false)
              }
            }
            else
            {
              showedThisSection = false
              titleTimer?.invalidate()
              titleView.hide()
            }
          }
        }
        indicatorBackground.updateLocation(yPos: yPos, sectionProgress:  percent)
        
      }else if keyPath == #keyPath(UIScrollView.contentSize)
      {
        print("CONTENT SIZE")
        indicatorBackground.placeBackgroundView()
      }
    }
  }
}

extension EAScrollIndicator
{
  // TIMER
  @objc private func timerFired()
  {
    titleTimer?.invalidate()
    titleView.hide()
  }
}
extension EAScrollIndicator
{
  
  /** PRIVATE ****************************/
  
  fileprivate func setUpBackground(){
    
    // Set up EAIndicatorBackground
    indicatorBackground = EAIndicatorBackground(width: 30, scrollView: self.scrollView!,
                                                indicator: EAIndicator(color: .purple, corner: 2))
    
    self.scrollView?.superview?.addSubview(indicatorBackground)
    self.scrollView?.superview?.addSubview(titleView)
    titleView.setUp()
    titleView.hide()
    indicatorBackground.placeBackgroundView()
    NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

  }
  
  fileprivate func scrollViewObserver()
  {
    // Set up observer
    self.scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.old, .new], context: nil)
    self.scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize  ), options: [.old, .new], context: nil)

  }
  @objc fileprivate func rotated()
  {
    if UIDevice.current.orientation.isLandscape
    {
      indicatorBackground.updateHeight()
    }
    else
    {
      indicatorBackground.updateHeight()
    }
  }
  
}

/****** OBJECT EXTENSIONS *********/
extension UIView {
  func round(corners: UIRectCorner, radius: CGFloat)
  {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}

extension UIColor {
  func darker(by percentage:CGFloat=30.0) -> UIColor? {
    return self.adjust(by: -1 * abs(percentage) )
  }
  func adjust(by percentage:CGFloat=30.0) -> UIColor? {
    var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
    if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
      return UIColor(red: min(r + percentage/100, 1.0),
                     green: min(g + percentage/100, 1.0),
                     blue: min(b + percentage/100, 1.0),
                     alpha: a)
    }else{
      return nil
    }
  }
}



