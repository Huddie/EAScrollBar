//
//  EAScrollTitleView.swift
//  EAScrollBar
//
//  Created by Ehud Adler on 2/1/18.
//  Copyright © 2018 Ehud Adler. All rights reserved.
//

import UIKit

public class EAScrollTitleView: UIView
{
  
  let titleLabel: UILabel = {
    let label                      = UILabel()
    label.backgroundColor          = .clear
    label.textAlignment            = .center
    label.numberOfLines            = 2
    label.isUserInteractionEnabled = false
    return label
  }()
  
  var title: String
  {
    set{ titleLabel.text = newValue }
    get{ return titleLabel.text! }
  }
  
  override init(frame: CGRect)
  {
    super.init(frame: frame)
  }
  
  public required init?(coder aDecoder: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }
  
  convenience init(title: String)
  {
    self.init()
    self.isUserInteractionEnabled = false
    self.layer.cornerRadius       = 10
    self.clipsToBounds            = true
    titleLabel.text               = title
  }
  
  fileprivate func addBlur(){
    
    let blurEffect                          = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
    let blurEffectView                      = UIVisualEffectView(effect: blurEffect)
    blurEffectView.isUserInteractionEnabled = false
    self.addSubview(blurEffectView)

    blurEffectView.translatesAutoresizingMaskIntoConstraints                         = false
    blurEffectView.topAnchor.constraint(equalTo:       self.topAnchor).isActive      = true
    blurEffectView.rightAnchor.constraint(equalTo:     self.rightAnchor).isActive    = true
    blurEffectView.leftAnchor.constraint(equalTo:      self.leftAnchor).isActive     = true
    blurEffectView.bottomAnchor.constraint(equalTo:    self.bottomAnchor).isActive   = true
    
    blurEffectView.contentView.addSubview(titleLabel)
    blurEffectView.alpha = 0.8

    titleLabel.translatesAutoresizingMaskIntoConstraints                                 = false
    titleLabel.topAnchor.constraint(equalTo:       blurEffectView.topAnchor).isActive    = true
    titleLabel.rightAnchor.constraint(equalTo:     blurEffectView.rightAnchor).isActive  = true
    titleLabel.leftAnchor.constraint(equalTo:      blurEffectView.leftAnchor).isActive   = true
    titleLabel.bottomAnchor.constraint(equalTo:    blurEffectView.bottomAnchor).isActive = true
    
    blurEffectView.layer.cornerRadius = 10
    blurEffectView.clipsToBounds      = true
    
  }
  
  fileprivate func _setUp(){
    
    if let superView = self.superview  {  // Check for safe unwrap
      
      self.translatesAutoresizingMaskIntoConstraints                                   = false
      self.topAnchor.constraint(equalTo: superView.topAnchor, constant: 40).isActive   = true
      self.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive         = true
      self.widthAnchor.constraint(equalToConstant: superView.frame.width / 1.5).isActive = true
      self.heightAnchor.constraint(equalToConstant:  50).isActive                      = true
      addBlur()
      
    }
  }
  
  public func hide(){self.alpha = 0}
  public func setUp(){ _setUp() }
  public func setTitle(title: String){ self.titleLabel.text = title; self.alpha = 1 }
}
