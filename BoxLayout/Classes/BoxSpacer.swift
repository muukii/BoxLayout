//
//  Spacer.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/20.
//

import Foundation

public struct BoxVSpacer : ContainerBoxType {
  
  public let minLength: CGFloat?
  
  public init(minLength: CGFloat? = nil) {
    self.minLength = minLength
  }
  
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
    
    let guide = resolver.makeLayoutGuide()
            
    if let minLength = minLength {
      let c = guide.heightAnchor.constraint(greaterThanOrEqualToConstant: minLength)
      resolver.append(constraint: c)
    }
        
    let c = guide.heightAnchor.constraint(equalToConstant: 1000)
    c.priority = .init(60)
    resolver.append(constraint: c)
      
    return .single(BoxElement(UIView()))
  }
  
}

public struct BoxHSpacer : BoxType {
  
  public let minLength: CGFloat?
  public let container: UIView = UIView()
  
  public init(minLength: CGFloat? = nil) {
    self.minLength = minLength
  }
  
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
    
    let guide = resolver.makeLayoutGuide()
    
    if let minLength = minLength {
      let c = guide.widthAnchor.constraint(greaterThanOrEqualToConstant: minLength)
      resolver.append(constraint: c)
    }
    
    let c = guide.widthAnchor.constraint(equalToConstant: 1000)
    c.priority = .init(60)
    resolver.append(constraint: c)
    
    return .single(BoxElement(UIView()))
  }
  

}
