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
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    padding: UIEdgeInsets,
    @BoxBuilder content: () -> Box
    ) {
    
    self.content = content()
    self.container = container()
    self.padding = padding
  }
  
  public func apply() -> BoxApplying {
    
    let result = content.apply()
    
    let view = result.rootElement.body
    
    container.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return
      BoxApplying(
        rootElement: BoxElement(container),
        constraints: result.constraints + [
          view.topAnchor.constraint(equalTo: container.topAnchor, constant: padding.top),
          view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -padding.right),
          view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padding.bottom),
          view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: padding.left),
        ]
    )
    
  }
}

public struct BoxInset<Box: BoxType> : ContainerBoxType {
  
  public let insets: UIEdgeInsets
  public let content: Box
  public let container: UIView
  
  public init(container: () -> UIView = { BoxNonRenderingView() }, insets: UIEdgeInsets, @BoxBuilder content: () -> Box) {
    self.content = content()
    self.container = container()
    self.insets = insets
  }
  
  public func apply() -> BoxApplying {
    
    let result = content.apply()
    
    let view = result.rootElement.body
    
    container.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
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
    
    return BoxApplying(
      rootElement: BoxElement(container),
      constraints: result.constraints + constraints
    )
    
  }
  
}

public struct BoxCenter<Box : BoxType> : ContainerBoxType {
  
  public let content: Box
  public let container: UIView
  
  public init(container: () -> UIView = { BoxNonRenderingView() }, @BoxBuilder content: () -> Box) {
    self.content = content()
    self.container = container()
  }
  
  public func apply() -> BoxApplying {
    
    let result = content.apply()
    
    let view = result.rootElement.body
    
    container.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return
      BoxApplying(
        rootElement: BoxElement(container),
        constraints: result.constraints + [
          view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
          view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        ]
    )
  }
}
