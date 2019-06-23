//
//  BoxLayout.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/19.
//  Copyright © 2019 muukii. All rights reserved.
//

import UIKit

open class BoxContainerView : UIView {
  
  private(set) public var currentConstraints: [NSLayoutConstraint] = []
  
  private var resolved: BoxResolver?
  
  public init() {
    super.init(frame: .zero)
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open func boxLayoutThatFits() -> BoxType {
    return BoxEmpty()
  }
  
  public func update() {
    
    cleanup()
    
    let content = boxLayoutThatFits()
    var resolver = BoxResolver()
    let result = content.apply(resolver: &resolver)
    guard case .single(let element) = result else {
      fatalError()
    }
    let view = element.body
    
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

public enum BoxApplyResult {
  case single(BoxElement)
  case multiple([BoxElement])
  
  var elements: [BoxElement] {
    switch self {
    case .single(let e):
      return [e]
    case .multiple(let e):
      return e
    }
  }
}

public protocol BoxType {
  
  typealias Modified<T> = Self
  
  func apply(resolver: inout BoxResolver) -> BoxApplyResult
}

public protocol BoxFrameType where Self : BoxType {
  
  var frame: BoxFrame { get set }
}

public protocol ContainerBoxType : BoxType {
  
  var container: UIView { get }
}

public struct BoxEmpty : BoxType, BoxFrameType, ContainerBoxType {
  
  public let container: UIView = BoxNonRenderingView()
  
  public var frame: BoxFrame = .init()
  
  public init() {
    
  }
  
  public func apply(resolver: inout BoxResolver) -> BoxApplyResult {
    
    resolver.append(container: container)
    resolver.append(constraints: makeConstraints(view: container))
    
    return .single(BoxElement(container))
  }
  
}

public struct BoxMultiple : BoxType {
  
  public let contents: [BoxType]
  
  public init(contents: () -> [BoxType]) {
    self.contents = contents()
  }
  
  public func apply(resolver: inout BoxResolver) -> BoxApplyResult {
    .multiple(
      contents.flatMap { r -> [BoxElement] in
        switch r.apply(resolver: &resolver) {
        case .single(let element):
          return [element]
        case .multiple(let elements):
          return elements
        }
      }
    )
    
  }
}

public struct BoxCondition<TrueContent : BoxType, FalseContent : BoxType> : BoxType {
  
  let trueContent: TrueContent?
  let falseContent: FalseContent?
  
  init(trueContent: TrueContent) {
    self.trueContent = trueContent
    self.falseContent = nil
  }
  
  init(falseContent: FalseContent) {
    self.trueContent = nil
    self.falseContent = falseContent
  }
  
  public func apply(resolver: inout BoxResolver) -> BoxApplyResult {
    if let trueContent = trueContent {
      return trueContent.apply(resolver: &resolver)
    }
    if let falseContent = falseContent {
      return falseContent.apply(resolver: &resolver)
    }
    fatalError()
  }
  
}

public struct BoxFrame {
  
  public enum BoxSizing {
    
    public enum SideLength {
      case width(CGFloat)
      case height(CGFloat)
    }
    
    case size(width: CGFloat?, height: CGFloat?)
    case aspectRatio(CGSize, sideLength: SideLength?)
  }
  
  public var sizing: BoxSizing?
  
}

public struct BoxElement: BoxType, BoxFrameType {
  
  public var frame: BoxFrame = .init()
  
  public let body: UIView
  
  public init(_ view: UIView) {
    self.body = view
  }
  
  public init(view: () -> UIView) {
    self.body = view()
  }
  
  public func apply(resolver: inout BoxResolver) -> BoxApplyResult {
    
    body.translatesAutoresizingMaskIntoConstraints = false
    
    resolver.append(
      constraints: makeConstraints(view: body)
    )

    return .single(self)
  }
 
}

extension BoxFrameType {
  
  public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Modified<BoxElement> {
    var _self = self
    _self.frame.sizing = .size(width: width, height: height)
    return _self
  }
  
  public func aspectRatio(ratio: CGSize, sideLength: BoxFrame.BoxSizing.SideLength? = nil) -> Modified<BoxElement> {
    var _self = self
    _self.frame.sizing = .aspectRatio(ratio, sideLength: sideLength)
    return _self
  }
  
  func makeConstraints(view: UIView) -> [NSLayoutConstraint] {
    
    var constraints: [NSLayoutConstraint] = []
    
    switch frame.sizing {
    case let .some(.size(width, height)):
      if let width = width {
        constraints.append(
          view.widthAnchor.constraint(equalToConstant: width)
        )
      }
      if let height = height {
        constraints.append(
          view.heightAnchor.constraint(equalToConstant: height)
        )
      }
      
    case let .some(.aspectRatio(ratio, sideLength)):
      
      constraints.append(
        view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: ratio.height / ratio.width)
      )
      
      switch sideLength {
      case .some(.width(let width)):
        constraints.append(
          view.widthAnchor.constraint(equalToConstant: width)
        )
      case .some(.height(let height)):
        constraints.append(
          view.heightAnchor.constraint(equalToConstant: height)
        )
      case .none:
        break
      }
      
    case .none:
      break
    }
    
    return constraints
  }
  
  #if swift(>=5.1)
  
  public func padding(_ padding: UIEdgeInsets) -> BoxPadding<Self> {
    BoxPadding(padding: padding, content: { self })
  }
  
  #else
  
  #endif
}
