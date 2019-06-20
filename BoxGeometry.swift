//
//  BoxGeometry.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/20.
//

import Foundation

public struct BoxPadding<Box : BoxType> : ContainerBoxType {
  
  public let padding: UIEdgeInsets
  public let content: Box
  public let container: UIView
  
  #if swift(>=5.1)
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    padding: UIEdgeInsets,
    @BoxBuilder content: () -> Box
    ) {
    
    self.content = content()
    self.container = container()
    self.padding = padding
  }
  
  #else
  
  #endif
  
  public func apply(resolver: inout BoxResolver) -> BoxElement {
    
    let result = content.apply(resolver: &resolver)
    let view = result.body
    
    container.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    resolver.append(container: container)
    resolver.append(constraints: [
      view.topAnchor.constraint(equalTo: container.topAnchor, constant: padding.top),
      view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -padding.right),
      view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padding.bottom),
      view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: padding.left),
      ])
    
    return BoxElement(container)
    
  }
 
}

public struct BoxInset<Box: BoxType> : ContainerBoxType {
  
  public let insets: UIEdgeInsets
  public let content: Box
  public let container: UIView
  
  #if swift(>=5.1)
  
  public init(container: () -> UIView = { BoxNonRenderingView() }, insets: UIEdgeInsets, @BoxBuilder content: () -> Box) {
    self.content = content()
    self.container = container()
    self.insets = insets
  }
  
  #else
  
  #endif
  
  public func apply(resolver: inout BoxResolver) -> BoxElement {
    
    let result = content.apply(resolver: &resolver)
    let view = result.body
    
    container.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    resolver.append(container: container)
   
    var constraints: [NSLayoutConstraint] = []
    
    if insets.top.isFinite {
      let c = view.topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top)
      constraints.append(c)
    } else {
      let c = view.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 0)
      constraints.append(c)
    }
    
    if insets.right.isFinite {
      let c = view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -insets.right)
      constraints.append(c)
    } else {
      let c = view.rightAnchor.constraint(lessThanOrEqualTo: container.rightAnchor, constant: 0)
      constraints.append(c)
    }
    
    if insets.bottom.isFinite {
      let c = view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom)
      constraints.append(c)
    } else {
      let c = view.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: 0)
      constraints.append(c)
    }
    
    if insets.left.isFinite {
      let c = view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: insets.left)
      constraints.append(c)
    } else {
      let c = view.leftAnchor.constraint(greaterThanOrEqualTo: container.leftAnchor, constant: 0)
      constraints.append(c)
    }
    
    resolver.append(constraints: constraints)
    
    return BoxElement(container)
    
  }
  
}

public struct BoxCenter<Box : BoxType> : ContainerBoxType {
  
  public let content: Box
  public let container: UIView
  
  #if swift(>=5.1)
  
  public init(container: () -> UIView = { BoxNonRenderingView() }, @BoxBuilder content: () -> Box) {
    self.content = content()
    self.container = container()
  }
  
  #else
  
  #endif
  
  public func apply(resolver: inout BoxResolver) -> BoxElement {
    
    let result = content.apply(resolver: &resolver)
    let view = result.body
    
    container.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    resolver.append(container: container)
    resolver.append(constraints: [
      view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      ])
    
    return BoxElement(container)
  }
}
