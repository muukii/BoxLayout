//
//  Spacer.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/20.
//

import Foundation

public struct BoxVSpacer : ContainerBoxType {
  
  public let minLength: CGFloat?
  public let container: UIView = UIView()
  
  public init(minLength: CGFloat? = nil) {
    self.minLength = minLength
  }
  
  public func apply(resolver: inout BoxResolver) -> BoxElement {
    
    if let minLength = minLength {
      let c = container.heightAnchor.constraint(greaterThanOrEqualToConstant: minLength)
      resolver.append(constraint: c)
    }
        
    let c = container.heightAnchor.constraint(equalToConstant: 1000)
    c.priority = .init(60)
    resolver.append(constraint: c)
    
    resolver.append(container: container)
  
    return BoxElement(container)
  }
  
}

public struct BoxHSpacer : BoxType {
  
  public let minLength: CGFloat?
  public let container: UIView = UIView()
  
  public init(minLength: CGFloat? = nil) {
    self.minLength = minLength
  }
  
  public func apply(resolver: inout BoxResolver) -> BoxElement {
    
    if let minLength = minLength {
      let c = container.widthAnchor.constraint(greaterThanOrEqualToConstant: minLength)
      resolver.append(constraint: c)
    }
    
    let c = container.widthAnchor.constraint(equalToConstant: 1000)
    c.priority = .init(60)
    resolver.append(constraint: c)
    
    resolver.append(container: container)
    
    return BoxElement(container)
  }
  

}
