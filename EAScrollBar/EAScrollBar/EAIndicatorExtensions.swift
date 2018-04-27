//
//  EAScrollBarExtensions.swift
//  EAScrollBar
//
//  Created by Ehud Adler on 4/27/18.
//  Copyright © 2018 Ehud Adler. All rights reserved.
//

import UIKit

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
  
  func darker(by percentage:CGFloat=30.0) -> UIColor? { return self.adjust(by: -1 * abs(percentage) ) }
  
  func adjust(by percentage:CGFloat=30.0) -> UIColor? {
    var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0;
    if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
      return UIColor(red: min(r + percentage/100, 1.0),
                     green: min(g + percentage/100, 1.0),
                     blue: min(b + percentage/100, 1.0),
                     alpha: a)
      
    } else { return nil }
  }
}
