//
//  BoxStack.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/20.
//

import Foundation

public struct BoxZStack : ContainerBoxType, BoxFrameType {
  
  public var frame: BoxFrame = .init()
  public let content: BoxMultiple
  public let container: UIView
  
  #if swift(>=5.1)
  
  public init(container: () -> UIView = { BoxNonRenderingView() }, @BoxBuilder content: () -> BoxMultiple) {
    self.content = content()
    self.container = container()
  }
  
  public init<Box: BoxType>(container: () -> UIView = { BoxNonRenderingView() }, @BoxBuilder content: () -> Box) {
    self.content = BoxMultiple { [content()] }
    self.container = container()
  }
  
  #else
  
  public init<Box: BoxType>(container: () -> UIView = { BoxNonRenderingView() }, content: () -> Box) {
    self.content = BoxMultiple { [content()] }
    self.container = container()
  }
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    content: () -> [BoxType]
    ) {
    self.content = BoxMultiple { content() }
    self.container = container()
  }
  
  public init(container: () -> UIView = { BoxNonRenderingView() }, content: () -> BoxMultiple) {
    self.content = content()
    self.container = container()
  }
  
  #endif
  
  public func apply(resolver: inout BoxResolver) -> BoxElement {
    
    resolver.append(container: container)    
    resolver.append(constraints: content.apply(resolver: &resolver).map { $0.body }.flatMap { view -> [NSLayoutConstraint] in
      
      container.addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false
      
      return [
        view.topAnchor.constraint(equalTo: container.topAnchor),
        view.rightAnchor.constraint(equalTo: container.rightAnchor),
        view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        view.leftAnchor.constraint(equalTo: container.leftAnchor),
      ]
    })
    
    resolver.append(constraints: makeConstraints(view: container))
    
    return BoxElement(container)
  }
  
}

// MARK: - BoxVStack

public struct BoxVStack : ContainerBoxType, BoxFrameType {
  
  public enum HorizontalAlignment {
    case leading
    case center
    case trailing
  }
  
  public var frame: BoxFrame = .init()
  public let spacing: CGFloat
  public let alignment: HorizontalAlignment
  public let content: BoxMultiple
  public let container: UIView
  
  #if swift(>=5.1)
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    spacing: CGFloat = 0,
    alignment: HorizontalAlignment = .center,
    @BoxBuilder content: () -> BoxMultiple
    ) {
    self.spacing = spacing
    self.alignment = alignment
    self.content = content()
    self.container = container()
  }
  
  public init<Box: BoxType>(
    container: () -> UIView = { BoxNonRenderingView() },
    spacing: CGFloat = 0,
    alignment: HorizontalAlignment = .center,
    @BoxBuilder content: () -> Box
    ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = BoxMultiple { [content()] }
    self.container = container()
  }
  
  #else
  
  public init<Box: BoxType>(
    container: () -> UIView = { BoxNonRenderingView() },
    spacing: CGFloat = 0,
    alignment: HorizontalAlignment = .center,
    content: () -> Box
    ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = BoxMultiple { [content()] }
    self.container = container()
  }
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    spacing: CGFloat = 0,
    alignment: HorizontalAlignment = .center,
    content: () -> [BoxType]
    ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = BoxMultiple { content() }
    self.container = container()
  }
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    spacing: CGFloat = 0,
    alignment: HorizontalAlignment = .center,
    content: () -> BoxMultiple
    ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
    self.container = container()
  }
  
  #endif
  
  public func apply(resolver: inout BoxResolver) -> BoxElement {
    
    let results = content.apply(resolver: &resolver)
    
    let views = results.map { $0.body }
    
    guard !views.isEmpty else { return BoxElement(container) }
    
    let width = container.heightAnchor.constraint(equalToConstant: 0)
    width.priority = .fittingSizeLevel
    
    resolver.append(constraints: [
      width
      ]
    )
    
    views.forEach { view in
      
      container.addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false
      
      resolver.append(constraints: [
        view.leadingAnchor.constraint(equalTo: container.leadingAnchor).withPriority(.defaultLow),
        view.trailingAnchor.constraint(equalTo: container.trailingAnchor).withPriority(.defaultLow),
        ]
      )
      
      switch alignment {
      case .leading:
        resolver.append(constraints: [
          view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
          view.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
          ]
        )
      case .center:
        resolver.append(constraints: [
          view.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor),
          view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
          view.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
          ]
        )
      case .trailing:
        resolver.append(constraints:
          [
            view.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
          ]
        )
      }
    }
    
    _ = views.dropFirst().reduce(views.first!) { pre, next in
      
      resolver.append(constraints:
        [
          pre.bottomAnchor.constraint(equalTo: next.topAnchor, constant: spacing),
        ]
      )
      
      return next
    }
    
    resolver.append(constraints:
      [
        views.first!.topAnchor.constraint(equalTo: container.topAnchor),
        views.last!.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      ]
    )
    
    resolver.append(container: container)
    resolver.append(constraints: makeConstraints(view: container))
    
    return BoxElement(container)
  }
  
}

// MARK: - BoxHStack

public struct BoxHStack : ContainerBoxType, BoxFrameType {
  
  public enum VerticalAlignment {
    case top
    case center
    case bottom
  }
  
  public var frame: BoxFrame = .init()
  public let alignment: VerticalAlignment
  public let content: BoxMultiple
  public let spacing: CGFloat
  public let container: UIView
  
  #if swift(>=5.1)
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    spacing: CGFloat = 0,
    alignment: VerticalAlignment = .center,
    @BoxBuilder content: () -> BoxMultiple
    ) {
    self.spacing = spacing
    self.alignment = alignment
    self.content = content()
    self.container = container()
  }
  
  public init<Box: BoxType>(
    container: () -> UIView = { BoxNonRenderingView() },
    spacing: CGFloat = 0,
    alignment: VerticalAlignment = .center,
    @BoxBuilder content: () -> Box
    ) {
    self.spacing = spacing
    self.alignment = alignment
    self.content = BoxMultiple { [content()] }
    self.container = container()
  }
  
  #else
  
  public init<Box: BoxType>(
    container: () -> UIView = { BoxNonRenderingView() },
    spacing: CGFloat = 0,
    alignment: VerticalAlignment = .center,
    content: () -> Box
    ) {
    self.spacing = spacing
    self.alignment = alignment
    self.content = BoxMultiple { [content()] }
    self.container = container()
  }
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    spacing: CGFloat = 0,
    alignment: VerticalAlignment = .center,
    content: () -> [BoxType]
    ) {
    self.spacing = spacing
    self.alignment = alignment
    self.content = BoxMultiple { content() }
    self.container = container()
  }
  
  public init(
    container: () -> UIView = { BoxNonRenderingView() },
    spacing: CGFloat = 0,
    alignment: VerticalAlignment = .center,
    content: () -> BoxMultiple
    ) {
    self.spacing = spacing
    self.alignment = alignment
    self.content = content()
    self.container = container()
  }
  
  #endif
  
  public func apply(resolver: inout BoxResolver) -> BoxElement {
    
    let results = content.apply(resolver: &resolver)
    
    let views = results.map { $0.body }
    
    guard !views.isEmpty else { return BoxElement(container) }
    
    let height = container.heightAnchor.constraint(equalToConstant: 0)
    height.priority = .fittingSizeLevel
    
    resolver.append(constraints: [
      height
      ]
    )
    
    views.forEach { view in
      
      container.addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false
      
      resolver.append(constraints: [
        view.topAnchor.constraint(equalTo: container.topAnchor).withPriority(.defaultLow),
        view.bottomAnchor.constraint(equalTo: container.bottomAnchor).withPriority(.defaultLow),
        ]
      )
      
      switch alignment {
      case .top:
        resolver.append(constraints: [
          view.topAnchor.constraint(equalTo: container.topAnchor),
          view.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor),
          ]
        )
      case .center:
        resolver.append(constraints: [
          view.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor),
          view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
          view.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor),
          ]
        )
      case .bottom:
        resolver.append(constraints:
          [
            view.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
          ]
        )
      }
    }
    
    _ = views.dropFirst().reduce(views.first!) { pre, next in
      
      resolver.append(constraints:
        [
          pre.rightAnchor.constraint(equalTo: next.leftAnchor, constant: spacing),
        ]
      )
      
      return next
    }
    
    resolver.append(constraints:
      [
        views.first!.leftAnchor.constraint(equalTo: container.leftAnchor),
        views.last!.rightAnchor .constraint(equalTo: container.rightAnchor),
      ]
    )
    
    resolver.append(container: container)
    resolver.append(constraints: makeConstraints(view: container))
    
    return BoxElement(container)
  }
  
}
