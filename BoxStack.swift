//
//  BoxStack.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/20.
//

import Foundation

public struct BoxZStack : ContainerBoxType {
  
  public let content: BoxMultiple
  public let container: UIView
  
  public init(container: () -> UIView = { BoxNonRenderingView() }, @BoxBuilder content: () -> BoxMultiple) {
    self.content = content()
    self.container = container()
  }
  
  public init<Box: BoxType>(container: () -> UIView = { BoxNonRenderingView() }, @BoxBuilder content: () -> Box) {
    self.content = BoxMultiple { [content()] }
    self.container = container()
  }
  
  public func apply() -> BoxApplying {
    
    let results = content.apply()
    
    return
      BoxApplying(
        rootElement: BoxElement(container),
        constraints: results.flatMap { $0.constraints } + results.map { $0.rootElement.body }.flatMap { view -> [NSLayoutConstraint] in
          
          container.addSubview(view)
          view.translatesAutoresizingMaskIntoConstraints = false
          
          return [
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.rightAnchor.constraint(equalTo: container.rightAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.leftAnchor.constraint(equalTo: container.leftAnchor),
          ]
        }
    )
    
  }
  
}

public struct BoxVStack : ContainerBoxType {
  
  public enum HorizontalAlignment {
    case leading
    case center
    case trailing
  }
  
  public let alignment: HorizontalAlignment
  public let content: BoxMultiple
  public let container: UIView
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    alignment: HorizontalAlignment = .center,
    @BoxBuilder content: () -> BoxMultiple
    ) {
    self.alignment = alignment
    self.content = content()
    self.container = container()
  }
  
  public init<Box: BoxType>(
    container: () -> UIView = { BoxNonRenderingView() },
    alignment: HorizontalAlignment = .center,
    @BoxBuilder content: () -> Box
    ) {
    self.alignment = alignment
    self.content = BoxMultiple { [content()] }
    self.container = container()
  }
  
  public func apply() -> BoxApplying {
    
    let results = content.apply()
    
    let views = results.map { $0.rootElement.body }
    
    let stack = UIStackView(arrangedSubviews: views)
    stack.axis = .vertical
    
    switch alignment {
    case .leading:
      stack.alignment = .leading
    case .center:
      stack.alignment = .center
    case .trailing:
      stack.alignment = .top
    }
    
    stack.distribution = .equalSpacing
    
    container.addSubview(stack)
    
    stack.translatesAutoresizingMaskIntoConstraints = false
    
    return
      BoxApplying(
        rootElement: BoxElement(container),
        constraints: results.flatMap { $0.constraints } + [
          stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
          stack.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor),
          stack.rightAnchor.constraint(equalTo: container.rightAnchor),
          stack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor),
          stack.leftAnchor.constraint(equalTo: container.leftAnchor),
        ]
    )
    
  }
  
}

public struct BoxHStack : ContainerBoxType {
  
  public enum VerticalAlignment {
    case top
    case center
    case bottom
  }
  
  public let alignment: VerticalAlignment
  public let content: BoxMultiple
  public let container: UIView
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    alignment: VerticalAlignment = .center,
    @BoxBuilder content: () -> BoxMultiple
    ) {
    self.alignment = alignment
    self.content = content()
    self.container = container()
  }
  
  public init<Box: BoxType>(
    container: () -> UIView = { BoxNonRenderingView() },
    alignment: VerticalAlignment = .center,
    @BoxBuilder content: () -> Box
    ) {
    self.alignment = alignment
    self.content = BoxMultiple { [content()] }
    self.container = container()
  }
  
  public func apply() -> BoxApplying {
    
    let results = content.apply()
    
    let views = results.map { $0.rootElement.body }
    
    let stack = UIStackView(arrangedSubviews: views)
    stack.axis = .horizontal
    
    switch alignment {
    case .top:
      stack.alignment = .top
    case .center:
      stack.alignment = .center
    case .bottom:
      stack.alignment = .bottom
    }
    
    stack.distribution = .equalSpacing
    
    container.addSubview(stack)
    
    stack.translatesAutoresizingMaskIntoConstraints = false
    
    return
      BoxApplying(
        rootElement: BoxElement(container),
        constraints: results.flatMap { $0.constraints } + [
          stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
          stack.topAnchor.constraint(equalTo: container.topAnchor),
          stack.rightAnchor.constraint(lessThanOrEqualTo: container.rightAnchor),
          stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
          stack.leftAnchor.constraint(greaterThanOrEqualTo: container.leftAnchor),
        ]
    )
  }
  
}
