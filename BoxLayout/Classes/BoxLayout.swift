//
//  BoxLayout.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/19.
//  Copyright © 2019 muukii. All rights reserved.
//

import UIKit

public final class BoxContainerView : UIView {
  
  public init<B : BoxType>(content: () -> B) {
    super.init(frame: .zero)
    
    let content = content()
    let view = content.apply().body
    
    addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: topAnchor),
      view.rightAnchor.constraint(equalTo: rightAnchor),
      view.bottomAnchor.constraint(equalTo: bottomAnchor),
      view.leftAnchor.constraint(equalTo: leftAnchor),
      ])
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public protocol BoxType {
  
  typealias Modified<T> = Self
  
  func apply() -> BoxElement
}

public protocol ContainerBoxType : BoxType {
  
  var container: UIView { get }
}

public struct BoxEmpty : BoxType {
  
  public init() {
    
  }
  
  public func apply() -> BoxElement {
    BoxElement(UIView())
  }
}

public struct BoxMultiple {
  
  public let contents: [BoxType]
  
  public init(contents: () -> [BoxType]) {
    self.contents = contents()
  }
  
  public func apply() -> [BoxElement] {
    contents.compactMap { $0.apply() }
  }
}

public struct BoxElement: BoxType {
  
  public var width: CGFloat?
  public var height: CGFloat?
  public let body: UIView
  
  public init(_ view: UIView) {
    self.body = view
  }
  
  public func apply() -> BoxElement {
    
    body.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      width.map { body.widthAnchor.constraint(equalToConstant: $0) },
      height.map { body.heightAnchor.constraint(equalToConstant: $0) },
      ].compactMap { $0 }
    )
    
    return self
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
  
  public func apply() -> BoxElement {
    
    let view = content.apply().body
    
    container.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
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
  
  public init(container: () -> UIView = { UIView() }, insets: UIEdgeInsets, @BoxBuilder content: () -> Box) {
    self.content = content()
    self.container = container()
    self.insets = insets
  }
  
  public func apply() -> BoxElement {
    
    let view = content.apply().body
    
    container.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    if insets.top.isFinite {
      let c = view.topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top)
      c.isActive = true
    } else {
      let c = view.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 0)
      c.isActive = true
    }
    
    if insets.right.isFinite {
      let c = view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -insets.right)
      c.isActive = true
    } else {
      let c = view.rightAnchor.constraint(lessThanOrEqualTo: container.rightAnchor, constant: 0)
      c.isActive = true
    }
    
    if insets.bottom.isFinite {
      let c = view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom)
      c.isActive = true
    } else {
      let c = view.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: 0)
      c.isActive = true
    }
    
    if insets.left.isFinite {
      let c = view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: insets.left)
      c.isActive = true
    } else {
      let c = view.leftAnchor.constraint(greaterThanOrEqualTo: container.leftAnchor, constant: 0)
      c.isActive = true
    }
    
    return BoxElement(container)
  }
  
}

public struct BoxCenter<Box : BoxType> : ContainerBoxType {

  public let content: Box
  public let container: UIView

  public init(container: () -> UIView = { UIView() }, @BoxBuilder content: () -> Box) {
    self.content = content()
    self.container = container()
  }
  
  public func apply() -> BoxElement {

    let view = content.apply().body

    container.addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      ])

    return BoxElement(container)
  }
}

public struct BoxZStack : ContainerBoxType {
  
  public let content: BoxMultiple
  public let container: UIView
  
  public init(container: () -> UIView = { UIView() }, @BoxBuilder content: () -> BoxMultiple) {
    self.content = content()
    self.container = container()
  }
  
  public init(container: () -> UIView = { UIView() }, @BoxBuilder content: () -> BoxElement) {
    self.content = BoxMultiple { [content()] }
    self.container = container()
  }
  
  public func apply() -> BoxElement {
    
    let views = content.apply().map { $0.body }
    
    views.forEach { view in
      
      container.addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: container.topAnchor),
        view.rightAnchor.constraint(equalTo: container.rightAnchor),
        view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        view.leftAnchor.constraint(equalTo: container.leftAnchor),
        ])
      
    }
    
    return BoxElement(container)
    
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
  
  public func apply() -> BoxElement {
    
    let views = content.apply().map { $0.body }
    
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
    
    NSLayoutConstraint.activate([
      stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      stack.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor),
      stack.rightAnchor.constraint(equalTo: container.rightAnchor),
      stack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor),
      stack.leftAnchor.constraint(equalTo: container.leftAnchor),
      ])
    
    return BoxElement(container)

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
  
  public func apply() -> BoxElement {
    
    let views = content.apply().map { $0.body }
    
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
    
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      stack.topAnchor.constraint(equalTo: container.topAnchor),
      stack.rightAnchor.constraint(lessThanOrEqualTo: container.rightAnchor),
      stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      stack.leftAnchor.constraint(greaterThanOrEqualTo: container.leftAnchor),
      ])
    
    return BoxElement(container)
  }
  
}

public struct BoxVSpacer : BoxType {
  
  public let minLength: CGFloat?
  
  public init(minLength: CGFloat? = nil) {
    self.minLength = minLength
  }
  
  public func apply() -> BoxElement {
    
    let view = UIView()
    
    if let minLength = minLength {
      let c = view.heightAnchor.constraint(greaterThanOrEqualToConstant: minLength)
      c.isActive = true
    }
    
    let c = view.heightAnchor.constraint(equalToConstant: 1000)
    c.priority = .fittingSizeLevel
    c.isActive = true
    
    return BoxElement(view)
  }
}

public struct BoxHSpacer : BoxType {
  
  public let minLength: CGFloat?
  
  public init(minLength: CGFloat? = nil) {
    self.minLength = minLength
  }
  
  public func apply() -> BoxElement {
    
    let view = UIView()
    
    if let minLength = minLength {
      let c = view.widthAnchor.constraint(greaterThanOrEqualToConstant: minLength)
      c.isActive = true
    }
    
    let c = view.widthAnchor.constraint(equalToConstant: 1000)
    c.priority = .fittingSizeLevel
    c.isActive = true
    
    return BoxElement(view)
  }
}
