//
//  EAScrollView+Indicator.swift
//  Edit
//
//  Created by Ehud Adler on 1/29/18.
//  Copyright © 2018 Ehud Adler. All rights reserved.
//

import UIKit

// MARK: EAScrollDelegate
public protocol EAScrollDelegate {
  func sectionPercent(percent: CGFloat)
}

public class EAScrollIndicator : NSObject
{
  
  // MARK: public variables
  public var indicatorBackground = EAIndicatorBackground()  // Hosting EAIndicatorBackground
  public var titleView = EAScrollTitleView()
  public var points : [EAIndicatorPoint]?
  
  
  // MARK: fileprivate constants
  fileprivate let _indicator : EAIndicator = EAIndicator(color: UIColor.purple)
  
  // MARK: fileprivate variables
  fileprivate var _previousScrollMoment: Date = Date()
  fileprivate var _previousScrollY: CGFloat = 0
  fileprivate var _indicatorColor : UIColor = UIColor.purple
  fileprivate var _shadeColor : UIColor = UIColor.purple
  fileprivate var _scrollDelegate : EAScrollDelegate?
  
  // MARK: public fileprivate(set) variables
  public fileprivate(set) weak var scrollView : UIScrollView?

  
  // MARK: Get/Set
  var indicatorColor: UIColor
  {
    get{ return (_indicator.indicatorColor) }
    set{ _indicator.indicatorColor = newValue }
  }
  
  var shadeColor: UIColor
  {
    get{ return _indicatorColor }
    set
    {
      _indicatorColor = newValue
      _indicator.indicatorColor = newValue
    }
  }

  
  // MARK: Initializers
  public override init() { super.init() }
  
  public init(scrollView: UIScrollView,
              indicatorColor: UIColor? = UIColor.purple,
              shadeColor: UIColor? = UIColor.purple,
              points: [EAIndicatorPoint]?) // Location given as CGFloat
  {
    super.init()
  
    _indicator.shadeColor = shadeColor ?? _indicator.shadeColor
    _indicator.indicatorColor = indicatorColor ?? _indicator.indicatorColor
    
    self.scrollView = scrollView
    self.points = points
    commonInit()

  }
  
  public init(scrollView: UIScrollView,
              indicatorColor: UIColor? = UIColor.purple,
              shadeColor: UIColor? = UIColor.purple,
              paths: [EAIndicatorPath]?) // Location given as IndexPath requires conversion
  {
    super.init()
    
    _indicator.shadeColor = shadeColor ?? _indicator.shadeColor
    _indicator.indicatorColor = indicatorColor ?? _indicator.indicatorColor
    
    self.scrollView = scrollView
    self.points = paths?.map { EAIndicatorPoint(title: $0.title,
                                                location: self.indexPathToOffset($0.indexPath)) }
    
    commonInit()
  }
  
  fileprivate func commonInit()
  {

    self.scrollView?.delegate = self
    
    self.points?.sort {$0.location < $1.location}

    self.scrollView?.showsVerticalScrollIndicator = false
    
    self.setUpBackground()
    self.setScrollViewObserver()
  }
  
  // MARK: Deinit
  deinit {
    NotificationCenter.default.removeObserver(self)
    if let activeScrollView = self.scrollView {
      activeScrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
      activeScrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
    }
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
        updateIndicator(yPos: yPos)
      }else if keyPath == #keyPath(UIScrollView.contentSize) { indicatorBackground.placeBackgroundView() }
    }
  }
}

// MARK: UIScrollViewDelegate
extension EAScrollIndicator: UIScrollViewDelegate
{
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
    titleView.hide()
  }
}
// MARK: fileprivate methods
extension EAScrollIndicator
{
  
  fileprivate func updateIndicator(yPos: CGFloat)
  {
    var percent : CGFloat = 0.0
    
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
        
        let difference = rightPos - leftPos // Full Difference
        let differenceFromPred = yPos - leftPos // Difference from pred
        percent = CGFloat(differenceFromPred * 100 / difference)   // Percent
        
        _scrollDelegate?.sectionPercent(percent: percent)
        
        let date = Date()
        let elapsed = Date().timeIntervalSince(_previousScrollMoment)
        let distance = (yPos - _previousScrollY)
        let velocity = (elapsed == 0) ? 0 : fabs(distance / CGFloat(elapsed))
        _previousScrollMoment = date
        _previousScrollY = yPos
        
        if velocity > 1000
        {
          titleView.setTitle(title: self.points![index].title)
        }
        else if velocity < 50 && velocity != 0
        {
          titleView.hide()
        }
      }
    }
    indicatorBackground.updateLocation(yPos: yPos, sectionProgress:  percent)
  }
  
  /// Set Up Backgorund Function
  /// Create the indicator background and add to the indicator object
  /// Called one time only.
  fileprivate func setUpBackground(){
    
    // Set up EAIndicatorBackground
    indicatorBackground = EAIndicatorBackground(width: 30,
                                                scrollView: self.scrollView!,
                                                indicator: _indicator)
    
    self.scrollView?.superview?.addSubview(indicatorBackground)
    self.scrollView?.superview?.addSubview(titleView)
    indicatorBackground.placeBackgroundView()
    NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    
    // Set up title
    titleView.setUp()
    titleView.hide()
  }
  
  /// SetScrollViewObservers
  /// Adds ContentOffset and ContentSize observers to scrollview
  /// ContentOffset - Used for updating the indicator (Percent, position and titleview)
  /// ContentSize   - Used for updating the indicator background in case of a size change
  fileprivate func setScrollViewObserver()
  {
    // Set up observer
    self.scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.old, .new], context: nil)
    self.scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize  ), options: [.old, .new], context: nil)
  }
  
  /// Index Path To Offset Function
  /// Converts IndexPath -> CGFloat
  fileprivate func indexPathToOffset(_ indexPath: IndexPath) -> CGFloat
  {

    if let tableview = self.scrollView as? UITableView
    {
      return tableview.rectForRow(at: indexPath).origin.y
    }
    else if let collectionView = self.scrollView as? UICollectionView
    {
      if let rect = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)?.frame
      {
        return rect.origin.y
      }
      assert(true, "Couldn't find frame for CollectionView IndexPath")
      return 0;
    }
    
    assert(true, "Scrollview is not a TableView or a CollectionView")
    return 0;
  }
  
  /// Rotated
  @objc fileprivate func rotated()
  {
    if UIDevice.current.orientation.isLandscape { indicatorBackground.updateHeight() }
    else { indicatorBackground.updateHeight() }
  }
}

