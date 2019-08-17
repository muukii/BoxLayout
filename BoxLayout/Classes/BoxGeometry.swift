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
      
  public init(
    padding: UIEdgeInsets,
    @BoxMultipleBuilder content: () -> Box
    ) {
    
    self.content = content()
    self.padding = padding
  }
    
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
    
    let guide = resolver.makeLayoutGuide()
            
    resolver.append(constraints: [
      guide.topAnchor.constraint(equalTo: parentLayoutGuide.topAnchor, constant: padding.top),
      guide.rightAnchor.constraint(equalTo: parentLayoutGuide.rightAnchor, constant: -padding.right),
      guide.bottomAnchor.constraint(equalTo: parentLayoutGuide.bottomAnchor, constant: -padding.bottom),
      guide.leftAnchor.constraint(equalTo: parentLayoutGuide.leftAnchor, constant: padding.left),
      ])
    
    return content.apply(resolver: &resolver, parentLayoutGuide: guide)
            
  }
 
}

//
//public struct BoxInset<Box: BoxType> : ContainerBoxType {
//
//  public let insets: UIEdgeInsets
//  public let content: Box
//  public let container: UIView
//
//  public init(
//    container: () -> UIView = { BoxNonRenderingView() },
//    insets: UIEdgeInsets,
//    @BoxMultipleBuilder content: () -> Box
//    ) {
//    self.content = content()
//    self.container = container()
//    self.insets = insets
//  }
//
//  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
//
//    let result = content.apply(resolver: &resolver)
//    let view = result.elements.first!.body
//
//    container.addSubview(view)
//    view.translatesAutoresizingMaskIntoConstraints = false
//
//    resolver.append(container: container)
//
//    var constraints: [NSLayoutConstraint] = []
//
//    if insets.top.isFinite {
//      let c = view.topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top)
//      constraints.append(c)
//    } else {
//      let c = view.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 0)
//      constraints.append(c)
//    }
//
//    if insets.right.isFinite {
//      let c = view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -insets.right)
//      constraints.append(c)
//    } else {
//      let c = view.rightAnchor.constraint(lessThanOrEqualTo: container.rightAnchor, constant: 0)
//      constraints.append(c)
//    }
//
//    if insets.bottom.isFinite {
//      let c = view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom)
//      constraints.append(c)
//    } else {
//      let c = view.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: 0)
//      constraints.append(c)
//    }
//
//    if insets.left.isFinite {
//      let c = view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: insets.left)
//      constraints.append(c)
//    } else {
//      let c = view.leftAnchor.constraint(greaterThanOrEqualTo: container.leftAnchor, constant: 0)
//      constraints.append(c)
//    }
//
//    resolver.append(constraints: constraints)
//
//    return .single(BoxElement(container))
//
//  }
//
//}

public struct BoxCenter<Box : BoxType> : ContainerBoxType {
  
  public let content: Box
      
  public init(
    @BoxMultipleBuilder content: () -> Box
    ) {
    self.content = content()
  }
    
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
    
    let guide = UILayoutGuide()
        
    resolver.append(constraints: [
      guide.centerYAnchor.constraint(equalTo: parentLayoutGuide.centerYAnchor),
      guide.centerXAnchor.constraint(equalTo: parentLayoutGuide.centerXAnchor),
      
      guide.topAnchor.constraint(greaterThanOrEqualTo: parentLayoutGuide.topAnchor),
      guide.rightAnchor.constraint(lessThanOrEqualTo: parentLayoutGuide.rightAnchor),
      guide.bottomAnchor.constraint(lessThanOrEqualTo: parentLayoutGuide.bottomAnchor),
      guide.leftAnchor.constraint(greaterThanOrEqualTo: parentLayoutGuide.leftAnchor),
      ])
    
    return content.apply(resolver: &resolver, parentLayoutGuide: guide)
  }
}
