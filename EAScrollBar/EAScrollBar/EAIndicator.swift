//
//  EAIndicator.swift
//  Siddur
//
//  Created by Ehud Adler on 1/29/18.
//  Copyright © 2018 Simple Siddur. All rights reserved.
//

import UIKit

public class EAIndicator: UIView
{

  /**** Private *********************************/
  
  private let _heightMultiplier : CGFloat = 0.05            // Value used to resize indicator height appropiratly                  [Constant]
  private var _topBottomPadding : CGFloat = 20.0            // Value used to determine top and bottom paddding                     [Get, Set]
  private var _minimumHeight    : CGFloat = 13.0            // Value used to determine minimum height of indicator when compressed [Get, Set]

  private var _indicatorWidth   : CGFloat  = 0.0            // The width of the indicator, matches width of EAIndicatorBackground  [Get]
  private var _indicatorHeight  : CGFloat  = 0.0            // The height of the indicator, matches height of EAIndicatorBackground
  
  private var _backgroundView   : EAIndicatorBackground?    // The EAIndicatorBackground which will host the indicator
  private var _heightConstraint : NSLayoutConstraint?       // Height Constraints of indicator which will allow for resizing
  private var _topConstraint    : NSLayoutConstraint?       // Top Constraints of indicator which will allow for proper alighment when resized

  
  /// Easily set, get the indicator width
  var indicatorWidth: CGFloat
  {
    get{ return _indicatorWidth }
  }
  
  /// Easily set, get the minimum height of the indicator
  var minimumHeight: CGFloat
  {
    set{ _minimumHeight = newValue }
    get{ return _minimumHeight }
  }
  
  /// Easily set, get the top/bottom padding
  var topBottomPadding: CGFloat
  {
    set{ _topBottomPadding = newValue }
    get{ return _topBottomPadding }
  }
  
  override init(frame: CGRect) { super.init(frame: frame) }
  required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
  
  
  convenience init(color: UIColor? = UIColor.gray, // Color of indicator
                   corner: CGFloat? = 2)           // Corner radius of top/bottom left corners
  {
    
    self.init()
    self.backgroundColor                           = color!
    self.translatesAutoresizingMaskIntoConstraints = false
  }
  
  /// This function will replace the indicator in the top of the EAIndicatorBackground that hosts it
  /// This function should only be called once, unless reset is requried
  ///
  /// Uses constraints
  private func _placeIndicator()
  {
    
    if let backgroundView = self.superview as? EAIndicatorBackground {  // Check for safe unwrap
      
      /* Set initial required values */
      _backgroundView  = backgroundView
      _indicatorHeight = backgroundView.height * _heightMultiplier
      _indicatorWidth  = backgroundView.width
      
      /* Constraints */
      self.rightAnchor.constraint(equalTo: backgroundView.rightAnchor).isActive  = true
      self.widthAnchor.constraint(equalTo: backgroundView.widthAnchor).isActive  = true

      _heightConstraint = self.heightAnchor.constraint(equalToConstant:  _indicatorHeight)
      _topConstraint    = self.topAnchor.constraint(equalTo:             backgroundView.topAnchor, constant: 0)
      
      _heightConstraint?.isActive = true
      _topConstraint?.isActive    = true
      /* End constraints */
      
    }
  }
  
  /// This function will update the location of the indicator within the host view
  private func _updateLocation(yPos: CGFloat){

    var newHeight: CGFloat = 0.0                                                                      // Blank height
    
    var convertedY = yPos * (_backgroundView?.height)! / (_backgroundView?.scrollViewContentHeight)!  // Converted Y to match the view rather then the contentSize
    
    
    convertedY = convertedY >= 0 ? convertedY : 0                                                     // Allow Y to be positive values only
    
    if convertedY <= _topBottomPadding                                                                // Check if we have passed the top padding and need to begin compression
    {
      newHeight = _indicatorHeight + abs(convertedY) - _topBottomPadding > _minimumHeight ?
                    _indicatorHeight + abs(convertedY) - _topBottomPadding : _minimumHeight
      
      _heightConstraint?.constant = newHeight
      _topConstraint?.constant = _topBottomPadding
    }
    else if convertedY >= (_backgroundView?.frame.height)! - _topBottomPadding                              // Check if we have passed bottom padding and need to begin compression
    {
      let difference = convertedY + _indicatorHeight - (_backgroundView?.frame.height)! - _topBottomPadding // Some pos. number
      newHeight                   = _indicatorHeight - difference > _minimumHeight ?
                                    _indicatorHeight - difference : _minimumHeight
      
      _heightConstraint?.constant = newHeight
      _topConstraint?.constant    = (_backgroundView?.frame.height)! - _topBottomPadding - (_heightConstraint?.constant)! // Reposition top
    }
    else                                                                                                                  // Normal update, resize indicator height to identi
    {
      _heightConstraint?.constant = _indicatorHeight
      _topConstraint?.constant =  convertedY * (_backgroundView?.height)! / (_backgroundView?.scrollViewContentHeight)!
    }
    self.updateConstraints()
  }
  public func placeIndicator() { _placeIndicator() }
  public func updateLocation(yPos: CGFloat) { _updateLocation(yPos: yPos) }
}


