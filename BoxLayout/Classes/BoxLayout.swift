//
//  BoxLayout.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/19.
//  Copyright © 2019 muukii. All rights reserved.
//

import UIKit

public final class BoxContainerView<Box: BoxType> : UIView {
  
  private(set) public var currentConstraints: [NSLayoutConstraint] = []
  
  private var resolved: BoxResolver?
  
  private let contentFactory: () -> Box
  
  public init(content: @escaping () -> Box) {
    self.contentFactory = content
    super.init(frame: .zero)
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func update() {
    
    cleanup()
    
    let content = contentFactory()
    var resolver = BoxResolver()
    let result = content.apply(resolver: &resolver)
    let view = result.body
    
    addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate(resolver.constraints + [
      view.topAnchor.constraint(equalTo: topAnchor),
      view.rightAnchor.constraint(equalTo: rightAnchor),
      view.bottomAnchor.constraint(equalTo: bottomAnchor),
      view.leftAnchor.constraint(equalTo: leftAnchor),
      ])
    
    resolved = resolver
    
  }
  
  private func cleanup() {
    
    guard let resolved = resolved else { return }
    
    subviews.forEach { $0.removeFromSuperview() }    
    NSLayoutConstraint.deactivate(resolved.constraints)
    resolved.containers.forEach { $0.removeFromSuperview() }
  }
  
}

public struct BoxResolver {
  
  public var constraints: [NSLayoutConstraint] = []
  public var containers: [UIView] = []
  
  mutating func append(constraint: NSLayoutConstraint) {
    self.constraints.append(constraint)
  }
  
  mutating func append(constraints: [NSLayoutConstraint]) {
    self.constraints.append(contentsOf: constraints)
  }
  
  mutating func append(container: UIView) {
    self.containers.append(container)
  }
  
}

public protocol BoxType {
  
  typealias Modified<T> = Self
  
  func apply(resolver: inout BoxResolver) -> BoxElement
}

public protocol ContainerBoxType : BoxType {
  
  var container: UIView { get }
}

public struct BoxEmpty : BoxType {
  
  public init() {
    
  }
  
  public func apply(resolver: inout BoxResolver) -> BoxElement {
    return BoxElement(UIView())
  }
  
}

public struct BoxMultiple {
  
  public let contents: [BoxType]
  
  public init(contents: () -> [BoxType]) {
    self.contents = contents()
  }
  
  public func apply(resolver: inout BoxResolver) -> [BoxElement] {
    return contents.compactMap { $0.apply(resolver: &resolver) }
  }
}

public struct BoxElement: BoxType {
  
  public var width: CGFloat?
  public var height: CGFloat?
  public let body: UIView
  
  public init(_ view: UIView) {
    self.body = view
  }
  
  public func apply(resolver: inout BoxResolver) -> BoxElement {
    
    body.translatesAutoresizingMaskIntoConstraints = false
    
    resolver.append(
      constraints: [
        width.map { body.widthAnchor.constraint(equalToConstant: $0) },
        height.map { body.heightAnchor.constraint(equalToConstant: $0) },
        ]
        .compactMap { $0 }
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
  
  #if swift(>=5.1)
  
  public func padding(_ padding: UIEdgeInsets) -> BoxPadding<Self> {
    BoxPadding(padding: padding, content: { self })
  }
  
  #else
  
  #endif
}
