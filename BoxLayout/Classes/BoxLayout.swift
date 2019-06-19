//
//  BoxLayout.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/19.
//  Copyright © 2019 muukii. All rights reserved.
//

import UIKit

public final class BoxContainerView : UIView {
  
  private(set) public var currentConstraints: [NSLayoutConstraint] = []
  
  public init<B : BoxType>(content: () -> B) {
    super.init(frame: .zero)
    
    let content = content()
    let result = content.apply()
    let view = result.rootElement.body
    
    addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate(result.constraints + [
      view.topAnchor.constraint(equalTo: topAnchor),
      view.rightAnchor.constraint(equalTo: rightAnchor),
      view.bottomAnchor.constraint(equalTo: bottomAnchor),
      view.leftAnchor.constraint(equalTo: leftAnchor),
      ])
    
    currentConstraints = result.constraints
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public struct BoxApplying {
  
  public let rootElement: BoxElement
  public let constraints: [NSLayoutConstraint]
  
  init(rootElement: BoxElement, constraints: [NSLayoutConstraint]) {
    self.rootElement = rootElement
    self.constraints = constraints
  }
  
}

public protocol BoxType {
  
  typealias Modified<T> = Self
  
  func apply() -> BoxApplying
}

public protocol ContainerBoxType : BoxType {
  
  var container: UIView { get }
}

public struct BoxEmpty : BoxType {
  
  public init() {
    
  }
  
  public func apply() -> BoxApplying {
    return .init(rootElement: BoxElement(UIView()), constraints: [])
  }
}

public struct BoxMultiple {
  
  public let contents: [BoxType]
  
  public init(contents: () -> [BoxType]) {
    self.contents = contents()
  }
  
  public func apply() -> [BoxApplying] {
    let result = contents.compactMap { $0.apply() }
    return result
  }
}

public struct BoxElement: BoxType {
  
  public var width: CGFloat?
  public var height: CGFloat?
  public let body: UIView
  
  public init(_ view: UIView) {
    self.body = view
  }
  
  public func apply() -> BoxApplying {
    
    body.translatesAutoresizingMaskIntoConstraints = false
    
    return
      BoxApplying(
        rootElement: self,
        constraints: [
          width.map { body.widthAnchor.constraint(equalToConstant: $0) },
          height.map { body.heightAnchor.constraint(equalToConstant: $0) },
          ].compactMap { $0 }
    )
    
  }
}

extension BoxElement {
  
  public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Modified<BoxElement> {
    var _self = self
    _self.width = width
    _self.height = height
    return _self
  }
  
  public func padding(_ padding: UIEdgeInsets) -> BoxPadding<Self> {
    BoxPadding(padding: padding, content: { self })
  }
}

public struct BoxPadding<Box : BoxType> : ContainerBoxType {
  
  public let padding: UIEdgeInsets
  public let content: Box
  public let container: UIView
  
  public init(
    container: () -> UIView = { UIView() },
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
  
  public init(container: () -> UIView = { UIView() }, insets: UIEdgeInsets, @BoxBuilder content: () -> Box) {
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
  
  public init(container: () -> UIView = { UIView() }, @BoxBuilder content: () -> Box) {
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

public struct BoxZStack : ContainerBoxType {
  
  public let content: BoxMultiple
  public let container: UIView
  
  public init(container: () -> UIView = { UIView() }, @BoxBuilder content: () -> BoxMultiple) {
    self.content = content()
    self.container = container()
  }
  
  public init<Box: BoxType>(container: () -> UIView = { UIView() }, @BoxBuilder content: () -> Box) {
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
    container: () -> UIView = { UIView() },
    alignment: HorizontalAlignment = .center,
    @BoxBuilder content: () -> BoxMultiple
    ) {
    self.alignment = alignment
    self.content = content()
    self.container = container()
  }
  
  public init<Box: BoxType>(
    container: () -> UIView = { UIView() },
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
    container: () -> UIView = { UIView() },
    alignment: VerticalAlignment = .center,
    @BoxBuilder content: () -> BoxMultiple
    ) {
    self.alignment = alignment
    self.content = content()
    self.container = container()
  }
  
  public init<Box: BoxType>(
    container: () -> UIView = { UIView() },
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
