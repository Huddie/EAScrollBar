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
  
  // MARK: fileprivate constants
  fileprivate let _heightMultiplier : CGFloat = 0.05 // Value used to resize indicator height appropiratly [Constant]
  
  // MARK: fileprivate variables
  fileprivate var _topBottomPadding : CGFloat = 20.0 // Value used to determine top and bottom paddding [Get, Set]
  fileprivate var _minimumHeight : CGFloat = 13.0 // Value used to determine minimum height of indicator when compressed [Get, Set]
  
  fileprivate var _indicatorWidth : CGFloat = 0.0  // The width of the indicator, matches width of EAIndicatorBackground [Get]
  fileprivate var _indicatorHeight : CGFloat = 0.0  // The height of the indicator, matches height of EAIndicatorBackground
  
  fileprivate var _backgroundView : EAIndicatorBackground? // The EAIndicatorBackground which will host the indicator
  fileprivate var _heightConstraint : NSLayoutConstraint?  // Height Constraints of indicator which will allow for resizing
  fileprivate var _topConstraint : NSLayoutConstraint?  // Top Constraints of indicator which will allow for proper alighment when resized
  fileprivate var _shadeTopConstraint : NSLayoutConstraint?  // Top Constraints of indicator which will allow for proper alighment when resized

  
  // View that covers the background view indicating how far down the section you are
  let shade: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .black
    return view
  }()
  
  let scroller: UIView = {
    let view = UIView()
    view.backgroundColor = .purple
    return view
  }()
  
  // MARK: Get/Set
  
  var indicatorColor: UIColor
  {
    get { return self.scroller.backgroundColor! }
    set { self.scroller.backgroundColor = newValue }
  }
  
  var shadeColor: UIColor
  {
    get { return self.shade.backgroundColor! }
    set { self.shade.backgroundColor = newValue.darker() }
  }
  
  var indicatorWidth: CGFloat
  {
    get{ return _indicatorWidth }
  }
  
  var minimumHeight: CGFloat
  {
    set{ _minimumHeight = newValue }
    get{ return _minimumHeight }
  }
  
  var topBottomPadding: CGFloat
  {
    set{ _topBottomPadding = newValue }
    get{ return _topBottomPadding }
  }
  
  // MARK: Initializers
  override init(frame: CGRect) { super.init(frame: frame) }
  required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
  
  convenience init(color: UIColor? = UIColor.gray) 
  {
    self.init()
    
    self.clipsToBounds = true
    self.backgroundColor = UIColor.clear
    self.scroller.backgroundColor = color ?? UIColor.blue
    self.shade.backgroundColor = color?.darker() ?? UIColor.blue.darker()
    self.translatesAutoresizingMaskIntoConstraints = false
  
  }
}

// MARK: fileprivate methods
extension EAIndicator
{
  /// This function will replace the indicator in the top of the EAIndicatorBackground that hosts it
  /// This function should only be called once, unless reset is requried
  ///
  /// Uses constraints
  fileprivate func _placeIndicator()
  {
    
    if let backgroundView = self.superview as? EAIndicatorBackground {  // Check for safe unwrap
      
      // Set initial required values
      _backgroundView  = backgroundView
      _indicatorHeight = backgroundView.height * _heightMultiplier
      _indicatorWidth  = backgroundView.width
      
      scroller.frame = CGRect(x: 0, y: 0, width: backgroundView.width, height: _indicatorHeight)
      scroller.addSubview(shade)
      self.addSubview(scroller)
      
      scroller.round(corners: [.topLeft, .bottomLeft], radius: 4)

      
      /* Constraints */
      
      self.rightAnchor.constraint(equalTo: backgroundView.rightAnchor).isActive = true
      self.widthAnchor.constraint(equalToConstant: backgroundView.width / 1.5).isActive = true
      
      _heightConstraint = self.heightAnchor.constraint(equalToConstant: _indicatorHeight)
      _topConstraint = self.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 0)
      
      _heightConstraint?.isActive = true
      _topConstraint?.isActive = true
      
      shade.rightAnchor.constraint(equalTo: scroller.rightAnchor).isActive = true
      shade.leftAnchor.constraint(equalTo: scroller.leftAnchor).isActive = true
      shade.bottomAnchor.constraint(equalTo: scroller.bottomAnchor).isActive = true
      
      
      _shadeTopConstraint = shade.topAnchor.constraint(equalTo: scroller.topAnchor,
                                                       constant: _indicatorHeight)

      
      _shadeTopConstraint?.isActive = true

      /* End constraints */
    }
    
    updateLocation(yPos: 0, sectionProgress: 0) // Set scrollview and progress to zero
    
  }

  /// This function will update the location of the indicator within the host view
  fileprivate func _updateLocation(yPos: CGFloat, sectionProgress: CGFloat)
  {

    // Update indicator
    var newHeight: CGFloat = _indicatorHeight
    
    var convertedY = yPos * (_backgroundView?.height)! / (_backgroundView?.scrollViewContentHeight)!
    convertedY = convertedY >= 0 ? convertedY : 0  /* Allow Y to be positive values only */
    
    // If passed top padding, begin compression
    if convertedY <= _topBottomPadding
    {
      
      newHeight = _indicatorHeight + abs(convertedY) - _topBottomPadding > _minimumHeight ?
                  _indicatorHeight + abs(convertedY) - _topBottomPadding : _minimumHeight
      
      _heightConstraint?.constant = newHeight
      _topConstraint?.constant = _topBottomPadding
    }
    else if convertedY >= (_backgroundView?.height)! - _topBottomPadding - _indicatorHeight // If passed bottom padding, begin compression
    {

      let difference = convertedY - ((_backgroundView?.height)!
                                  - _topBottomPadding
                                  - _indicatorHeight) // Some pos. number
      
      newHeight = _indicatorHeight - abs(difference) > _minimumHeight ?
                  _indicatorHeight - abs(difference) : _minimumHeight

      _heightConstraint?.constant = newHeight
      _topConstraint?.constant = (_backgroundView?.frame.height)! - _topBottomPadding
                                                                  - (_heightConstraint?.constant)! // Reposition top
      
    }
    else  // Normal update, resize indicator height to identity
    {
      _heightConstraint?.constant = _indicatorHeight
      _topConstraint?.constant = yPos * (_backgroundView?.height)!
                                      / (_backgroundView?.scrollViewContentHeight)!
    }
    
    // Update shade
    let convertedPercent  = sectionProgress / 100.0  * _indicatorHeight
    _shadeTopConstraint?.constant = _indicatorHeight - convertedPercent
    
    self.updateConstraints()
    scroller.frame = CGRect(x: 0, y: 0, width: (_backgroundView?.width)!, height: newHeight)
    scroller.round(corners: [.topLeft, .bottomLeft], radius: 4)
  }
}

// MARK: public methods
extension EAIndicator
{
  public func placeIndicator() { _placeIndicator() }
  public func updateLocation(yPos: CGFloat, sectionProgress: CGFloat) { _updateLocation(yPos: yPos, sectionProgress: sectionProgress) }
}

