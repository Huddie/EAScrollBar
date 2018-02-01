//
//  EAScrollView+Indicator.swift
//  Edit
//
//  Created by Ehud Adler on 1/29/18.
//  Copyright © 2018 Ehud Adler. All rights reserved.
//

import UIKit



public class EAScrollIndicator : NSObject
{
  /**** Private *********************************************/
  fileprivate var indicatorBackground = EAIndicatorBackground()  // Hosting EAIndicatorBackground
  
  /**** Public private(set) *********************************/
  public fileprivate(set) weak var scrollView : UIScrollView?
  public fileprivate(set) var points          : [EAIndicatorPoint]?
  
  public override init() { super.init() }
  
  public init(scrollView: UIScrollView, points: [EAIndicatorPoint]?)
  {
    super.init()
    
    self.scrollView                               = scrollView
    self.points                                   = points
    
    self.points?.sort {$0.location < $1.location}
    
    self.scrollView?.showsVerticalScrollIndicator = false
    
    self.setUpBackground()
    self.scrollViewObserver()
    
  }
  
  public func flush()
  {
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
        
        var percent: CGFloat = 0.0

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
          }
        }
        indicatorBackground.updateLocation(yPos: yPos, sectionProgress:  percent)
      }
    }
  }
}

extension EAScrollIndicator {
  
  /** PRIVATE ****************************/
  
  fileprivate func setUpBackground(){
    
    // Set up EAIndicatorBackground
    indicatorBackground = EAIndicatorBackground(width: 40, scrollView: self.scrollView!,
                                                indicator: EAIndicator(color: .purple, corner: 2))
    
    self.scrollView?.superview?.addSubview(indicatorBackground)
    indicatorBackground.placeBackgroundView()
  }
  
  fileprivate func scrollViewObserver()
  {
    // Set up observer
    self.scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.old, .new], context: nil)
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



