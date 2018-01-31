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
  
  /**** Private *********************************/
  fileprivate var indicatorBackground = EAIndicatorBackground()  // Hosting EAIndicatorBackground
  
  /**** Public private(set) *********************************/
  public fileprivate(set) weak var scrollView: UIScrollView?
  
  public override init() { super.init() }
  
  deinit {
    if let activeScrollView = self.scrollView { activeScrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset)) }
  }
  
  public init(scrollView: UIScrollView) {
    super.init()
    
    self.scrollView = scrollView
    self.scrollView?.showsVerticalScrollIndicator = false
    
    self.setUpBackground()
    self.scrollViewObserver()
    
  }
  
  override public func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
    
    
    if keyPath == #keyPath(UIScrollView.contentOffset) {
      let _loc = (object as? UIScrollView)?.contentOffset
      indicatorBackground.updateLocation(yPos: (_loc?.y)!)
    }
  }
}

extension EAScrollIndicator {
  
  /** PRIVATE ****************************/
  
  fileprivate func setUpBackground(){
    
    // Set up EAIndicatorBackground
    indicatorBackground = EAIndicatorBackground(width: 20, scrollView: self.scrollView!,
                                                indicator: EAIndicator(color: .purple, corner: 10))
    
    self.scrollView?.superview?.addSubview(indicatorBackground)
    
    indicatorBackground.placeBackgroundView()
  }
  
  fileprivate func scrollViewObserver(){
    // Set up observer
    self.scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.old, .new], context: nil)
  }
  
}


/****** OBJECT EXTENSIONS *********/
extension UIView {
  func round(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}

