//
//  EAIndicatorPoint.swift
//  EAScrollBar
//
//  Created by Ehud Adler on 2/1/18.
//  Copyright © 2018 Ehud Adler. All rights reserved.
//

import UIKit

public class EAIndicatorPoint : NSObject
  
{
  var title     : String
  var location  : CGFloat
  
  public override init()
  {
    self.title = ""
    self.location = 0.0
    super.init()
  }
  
  public init(title: String, location: CGFloat)
  {
    self.title    = title
    self.location = location
  }
}
