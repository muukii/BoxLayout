//
//  BoxMultipleBuilder.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/19.
//

import Foundation

#if swift(>=5.1)

@_functionBuilder
public struct BoxMultipleBuilder {
  
  public static func buildBlock() -> BoxEmpty {
    .init()
  }
  
  public static func buildBlock<Content : BoxType>(_ content: Content) -> Content {
    content
  }
  
  public static func buildBlock(_ contents: BoxType...) -> BoxMultiple {
    BoxMultiple(contents: { contents })
  }
  
  public static func buildBlock<Content : BoxType>(_ contents: Content...) -> BoxMultiple {
    BoxMultiple(contents: { contents })
  }
  
  public static func buildIf<Content: BoxType>(_ content: Content?) -> BoxMultiple {
    BoxMultiple(contents: { [content].compactMap { $0 } })
  }
  
  public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> BoxCondition<TrueContent, FalseContent> {
    .init(trueContent: first)
  }

  public static func buildEither<TrueContent, FalseContent>(second: FalseContent) -> BoxCondition<TrueContent, FalseContent> {
    .init(falseContent: second)
  }
}

#endif
