//
//  BoxBuilder.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/19.
//

import Foundation


#if swift(>=5.1)

@_functionBuilder
public struct BoxBuilder {
  
  public static func buildBlock() -> BoxEmpty {
    .init()
  }
  
//  public static func buildBlock<T : BoxType>(_ content: T) -> T {
//    content
//  }
  
  public static func buildBlock<T : BoxType>(_ content: T) -> BoxMultiple {
    BoxMultiple { [content] }
  }
  
  public static func buildBlock(_ content: BoxElement) -> BoxMultiple {
    BoxMultiple { [content] }
  }
  
  public static func buildBlock(_ content: UIView) -> BoxMultiple {
    BoxMultiple { [BoxElement(content)] }
  }
  
  public static func buildBlock(_ content: BoxMultiple) -> BoxMultiple {
    content
  }
  
  public static func buildBlock(_ contents: UIView...) -> BoxMultiple {
    BoxMultiple(contents: { contents.map(BoxElement.init) })
  }
  
  public static func buildBlock(_ contents: BoxType...) -> BoxMultiple {
    BoxMultiple(contents: { contents })
  }
  
  public static func buildBlock<T : BoxType>(_ contents: T...) -> BoxMultiple {
    BoxMultiple(contents: { contents })
  }
}

#endif
