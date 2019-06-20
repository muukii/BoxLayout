//
//  Spacer.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/20.
//

import Foundation

public struct BoxVSpacer : BoxType {
  
  public let minLength: CGFloat?
  
  public init(minLength: CGFloat? = nil) {
    self.minLength = minLength
  }
  
  public func apply() -> BoxApplying {
    
    let view = UIView()
    
    if let minLength = minLength {
      let c = view.heightAnchor.constraint(greaterThanOrEqualToConstant: minLength)
      c.isActive = true
    }
    
    let c = view.heightAnchor.constraint(equalToConstant: 1000)
    c.priority = .fittingSizeLevel
    
    return
      BoxApplying(
        rootElement: BoxElement(view),
        constraints: [
          c
        ]
    )
    
  }
}

public struct BoxHSpacer : BoxType {
  
  public let minLength: CGFloat?
  
  public init(minLength: CGFloat? = nil) {
    self.minLength = minLength
  }
  
  public func apply() -> BoxApplying {
    
    let view = UIView()
    
    if let minLength = minLength {
      let c = view.widthAnchor.constraint(greaterThanOrEqualToConstant: minLength)
      c.isActive = true
    }
    
    let c = view.widthAnchor.constraint(equalToConstant: 1000)
    c.priority = .fittingSizeLevel
    
    return
      BoxApplying(
        rootElement: BoxElement(view),
        constraints: [
          c
        ]
    )
    
  }
}
