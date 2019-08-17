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
  private let rootLayoutGuide = UILayoutGuide()
  
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
    
    let content = boxLayoutThatFits()
    var resolver = BoxResolver(rootView: self)
    resolver.append(layoutGuide: rootLayoutGuide)
    resolver.append(constraints: [
      rootLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
      rootLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
      rootLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
      rootLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    
    print(resolver)
    
    content.apply(resolver: &resolver, parentLayoutGuide: rootLayoutGuide)
    
    print(resolver)
    
    let k = resolver
    print(k.constraints.count)
                
    cleanup()
                
    resolver.children.forEach {
      addSubview($0)
    }
    
    resolver.layoutGuides.forEach {
      addLayoutGuide($0)
    }
    
    resolver.constraints.forEach {
      print($0)
//      $0.isActive = true
    }
           
    resolved = resolver
    
  }
  
  private func cleanup() {
    
    guard let resolved = resolved else { return }
    
    subviews.forEach { $0.removeFromSuperview() }    
    NSLayoutConstraint.deactivate(resolved.constraints)
    resolved.layoutGuides.forEach { $0.owningView?.removeLayoutGuide($0) }
  }
  
}

public struct BoxResolver {
  
  public var constraints: [NSLayoutConstraint] = []
  public var layoutGuides: [UILayoutGuide] = []
  public var children: [UIView] = []
  
  public let rootView: UIView
  
  init(rootView: UIView) {
    self.rootView = rootView
  }
  
  mutating func append(constraint: NSLayoutConstraint) {
    self.constraints.append(constraint)
  }
  
  mutating func append(constraints: [NSLayoutConstraint]) {
    constraints.forEach {
      self.constraints.append($0)
    }
    print(self.constraints)
  }
  
  mutating func append(layoutGuide: UILayoutGuide) {
    self.layoutGuides.append(layoutGuide)
  }
  
  mutating func append(child: UIView) {
    self.children.append(child)
  }
  
  mutating func makeLayoutGuide() -> UILayoutGuide {
    let guide = UILayoutGuide()
    append(layoutGuide: guide)
    return guide
  }
  
}

public enum BoxApplyResult {
  case empty
  case single(BoxElement)
  case multiple([BoxElement])
  
  var elements: [BoxElement] {
    switch self {
    case .empty:
      return []
    case .single(let e):
      return [e]
    case .multiple(let e):
      return e
    }
  }
}

public protocol BoxType {
  
  typealias Modified<T> = Self
  
  func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult
}

public protocol BoxFrameType where Self : BoxType {
  
  var frame: BoxFrame { get set }
}

public protocol ContainerBoxType : BoxType {
  
//  var layoutGuide: UILayoutGuide { get }
}

public struct BoxEmpty : BoxType, BoxFrameType, ContainerBoxType {
    
  public var frame: BoxFrame = .init()
  
  public init() {
    
  }
  
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
    
    let guide = resolver.makeLayoutGuide()
    
    let view = UIView()

    resolver.append(constraints: _edges(view: view, to: guide) + makeConstraints(guide: guide))
    resolver.append(child: view)
    
    return .single(BoxElement(view))
  }
    
}

public struct BoxMultiple : BoxType {
  
  public let contents: [BoxType]
  
  public init(contents: () -> [BoxType]) {
    self.contents = contents()
  }
  
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
   .multiple(
      contents.flatMap { r -> [BoxElement] in
        switch r.apply(resolver: &resolver, parentLayoutGuide: parentLayoutGuide) {
        case .single(let element):
          return [element]
        case .multiple(let elements):
          return elements
        case .empty:
          return []
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
  
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
    if let trueContent = trueContent {
      return trueContent.apply(resolver: &resolver, parentLayoutGuide: parentLayoutGuide)
    }
    if let falseContent = falseContent {
      return falseContent.apply(resolver: &resolver, parentLayoutGuide: parentLayoutGuide)
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
  
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
    
    body.translatesAutoresizingMaskIntoConstraints = false
    
    let guide = resolver.makeLayoutGuide()
    
    resolver.append(
      constraints: _edges(view: body, to: parentLayoutGuide)
    )
    resolver.append(child: body)
    
    return .single(self)
  }
 
}

func _edges(view: UIView, to guide: UILayoutGuide) -> [NSLayoutConstraint] {
          
  [
    view.topAnchor.constraint(equalTo: guide.topAnchor),
    view.rightAnchor.constraint(equalTo: guide.rightAnchor),
    view.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
    view.leftAnchor.constraint(equalTo: guide.leftAnchor),
    ]
  
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
  
  func makeConstraints(guide: UILayoutGuide) -> [NSLayoutConstraint] {
    
    var constraints: [NSLayoutConstraint] = []
    
    switch frame.sizing {
    case let .some(.size(width, height)):
      if let width = width {
        constraints.append(
          guide.widthAnchor.constraint(equalToConstant: width)
        )
      }
      if let height = height {
        constraints.append(
          guide.heightAnchor.constraint(equalToConstant: height)
        )
      }
      
    case let .some(.aspectRatio(ratio, sideLength)):
      
      constraints.append(
        guide.heightAnchor.constraint(equalTo: guide.widthAnchor, multiplier: ratio.height / ratio.width)
      )
      
      switch sideLength {
      case .some(.width(let width)):
        constraints.append(
          guide.widthAnchor.constraint(equalToConstant: width)
        )
      case .some(.height(let height)):
        constraints.append(
          guide.heightAnchor.constraint(equalToConstant: height)
        )
      case .none:
        break
      }
      
    case .none:
      break
    }
    
    return constraints
  }
    
  public func padding(_ padding: UIEdgeInsets) -> BoxPadding<Self> {
    BoxPadding(padding: padding, content: { self })
  }
  
}
