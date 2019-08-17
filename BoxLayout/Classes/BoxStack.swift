//
//  BoxStack.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/20.
//

import Foundation

public struct BoxZStack<Content: BoxType> : ContainerBoxType, BoxFrameType {
  
  public var frame: BoxFrame = .init()
  public let content: Content
    
  public init(@BoxMultipleBuilder content: () -> Content) {
    self.content = content()
  }
      
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
    
    resolver.append(constraints:
      content.apply(resolver: &resolver, parentLayoutGuide: parentLayoutGuide)
        .elements
        .map { $0.body }
        .flatMap { view -> [NSLayoutConstraint] in
          
          view.translatesAutoresizingMaskIntoConstraints = false
          
          return [
            view.topAnchor.constraint(equalTo: parentLayoutGuide.topAnchor),
            view.rightAnchor.constraint(equalTo: parentLayoutGuide.rightAnchor),
            view.bottomAnchor.constraint(equalTo: parentLayoutGuide.bottomAnchor),
            view.leftAnchor.constraint(equalTo: parentLayoutGuide.leftAnchor),
          ]
      }
    )
    
    return .empty
  }
  
}

// MARK: - BoxVStack

public struct BoxVStack<Content: BoxType> : ContainerBoxType, BoxFrameType {
  
  public enum HorizontalAlignment {
    case leading
    case center
    case trailing
  }
  
  public var frame: BoxFrame = .init()
  public let spacing: CGFloat
  public let alignment: HorizontalAlignment
  public let content: Content
    
  public init(
    spacing: CGFloat = 0,
    alignment: HorizontalAlignment = .center,
    @BoxMultipleBuilder content: () -> Content
    ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }
   
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
    
    let results = content.apply(resolver: &resolver, parentLayoutGuide: parentLayoutGuide)
    
    let views = results.elements.map { $0.body }
    let container = parentLayoutGuide
    
    guard !views.isEmpty else { return .empty }
    
    let width = container.heightAnchor.constraint(equalToConstant: 0)
    width.priority = .fittingSizeLevel
    
    resolver.append(constraints: [
      width
      ]
    )
    
    views.forEach { view in
      
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
    
//    resolver.append(constraints: makeConstraints(guide: parentLayoutGuide))
    
    return .empty
  }
  
}

// MARK: - BoxHStack

public struct BoxHStack<Content : BoxType> : ContainerBoxType, BoxFrameType {
  
  public enum VerticalAlignment {
    case top
    case center
    case bottom
  }
  
  public var frame: BoxFrame = .init()
  public let alignment: VerticalAlignment
  public let content: Content
  public let spacing: CGFloat
    
  public init(
    spacing: CGFloat = 0,
    alignment: VerticalAlignment = .center,
    @BoxMultipleBuilder content: () -> Content
    ) {
    self.spacing = spacing
    self.alignment = alignment
    self.content = content()
  }
  
  public func apply(resolver: inout BoxResolver, parentLayoutGuide: UILayoutGuide) -> BoxApplyResult {
    
    let guide = resolver.makeLayoutGuide()
    
    let results = content.apply(resolver: &resolver, parentLayoutGuide: guide)
    
    let views = results.elements.map { $0.body }
    let container = parentLayoutGuide
    
    guard !views.isEmpty else { return .empty }
    
    let height = container.heightAnchor.constraint(equalToConstant: 0)
    height.priority = .fittingSizeLevel
    
    resolver.append(constraints: [
      height
      ]
    )
    
    views.forEach { view in
      
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
    
//    resolver.append(constraints: makeConstraints(guide: parentLayoutGuide))
    
    return .empty
  }
  
}
