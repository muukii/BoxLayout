//
//  NonRenderingView.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/20.
//

import Foundation

public final class BoxNonRenderingView : UIView {
  
  public override class var layerClass: AnyClass {
    return CATransformLayer.self
  }
  
  public init() {
    super.init(frame: .zero)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
