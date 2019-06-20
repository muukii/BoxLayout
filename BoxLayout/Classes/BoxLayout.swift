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

public struct BoxResolver {
  
  public var constraints: [NSLayoutConstraint]
  public var containers: [UIView]
  
  mutating func append(constraints: [NSLayoutConstraint]) {
    self.constraints.append(contentsOf: constraints)
  }
  
  mutating func append(container: UIView) {
    self.containers.append(container)
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
