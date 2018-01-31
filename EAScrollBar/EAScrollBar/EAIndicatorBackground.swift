//
//  EAIndicatorBackground.swift
//  Siddur
//
//  Created by Ehud Adler on 1/30/18.
//  Copyright © 2018 Simple Siddur. All rights reserved.
//

import UIKit

public class EAIndicatorBackground: UIView {
  
  fileprivate var _width           : CGFloat   = 0.0                // Background width, will determine the indicator width
  fileprivate var _height          : CGFloat   = 0.0                // Background height
  fileprivate var _scrollView      : UIScrollView                   // scrollview (superview)
  fileprivate var _indicator       : EAIndicator                    // Indicator  (subview)
  fileprivate var _panGesture      = UIPanGestureRecognizer()       // Allow for scrolling

  var width: CGFloat
  {
    get{ return _width }
  }
  
  var height: CGFloat
  {
    get{ return _height }
  }
  
  var color: UIColor
  {
    set{ self.backgroundColor = color }
    get{ return self.backgroundColor! }
  }
  
  /// Converted content height
  ///
  /// - returns: content height in terms of EABackgroundView
  var scrollViewContentHeight: CGFloat
  {
    get{ return _scrollView.contentSize.height
                - _scrollView.bounds.height
                + _scrollView.contentInset.bottom }
  }
  
  override init(frame: CGRect)
  {
    _scrollView = UIScrollView()
    _indicator = EAIndicator()
    super.init(frame: frame)
  }
  required public init?(coder aDecoder: NSCoder)
  {
    _scrollView = UIScrollView()
    _indicator = EAIndicator()
    super.init(coder: aDecoder)
  }
  
  convenience init(width: CGFloat,
                   scrollView: UIScrollView,
                   indicator: EAIndicator){
    
    self.init()
    
    /* Initial Set up */
    
    _width                            = width
    _scrollView                       = scrollView
    _indicator                        = indicator
    _height                           = scrollView.frame.height
    _panGesture.cancelsTouchesInView  = true
    self.backgroundColor              = UIColor.groupTableViewBackground.withAlphaComponent(0.6)
  }
}

extension EAIndicatorBackground {
  
  /** PUBLIC ****************************/
  public func placeBackgroundView(){ _placeBackgroundView()}
  public func updateLocation(yPos: CGFloat) { _updateLocation(yPos: yPos) }
}

extension EAIndicatorBackground {
  
  /** PRIVATE ***************************/
  
  /// Passes the updated location to the indicator
  fileprivate func _updateLocation(yPos: CGFloat){ _indicator.updateLocation(yPos: yPos) }
  
  fileprivate func _placeBackgroundView()
  {
    self.translatesAutoresizingMaskIntoConstraints = false
    
    self.topAnchor.constraint(equalTo:            _scrollView.topAnchor).isActive      = true
    self.rightAnchor.constraint(equalTo:          _scrollView.rightAnchor).isActive    = true
    self.bottomAnchor.constraint(equalTo:         _scrollView.bottomAnchor).isActive   = true
    self.widthAnchor.constraint(equalToConstant:  _width).isActive                     = true
    
    /* Indicator Set Up */
    self.addSubview(_indicator)
    _panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
    _indicator.isUserInteractionEnabled = true
    _indicator.addGestureRecognizer(_panGesture)
    _indicator.placeIndicator()
  }
  
}
extension EAIndicatorBackground
{
  /*** GESTURES/TOUCHES ***************************/
  @objc func draggedView(_ sender:UIPanGestureRecognizer)
  {

    let location      = sender.translation(in: self)
    let yPosition     = location.y * scrollViewContentHeight / _height
    
    _scrollView.setContentOffset(CGPoint(x: _scrollView.contentOffset.x,
                                         y: _scrollView.contentOffset.y + yPosition),
                                         animated: false)
    
    sender.setTranslation(CGPoint.zero, in: self)

  }
  
  override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    let touch = touches.first!
    let location = touch.location(in: self)
    let yPosition = location.y * scrollViewContentHeight / _height
    _scrollView.setContentOffset(CGPoint(x: _scrollView.contentOffset.x, y: yPosition), animated: true)
  }
}


