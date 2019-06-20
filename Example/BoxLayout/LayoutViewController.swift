//
//  File.swift
//  BoxLayout_Example
//
//  Created by muukii on 2019/06/20.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

import BoxLayout

final class LayoutViewController : UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let root = BoxContainerView {
      BoxCenter {
        BoxVStack {
          BoxElement(UIView.make(backgroundColor: .red))
            .aspectRatio(ratio: CGSize(width: 1, height: 1))
          BoxElement(UIView.make(backgroundColor: .orange))
            .aspectRatio(ratio: CGSize(width: 1, height: 0.2))
          BoxZStack {
            BoxElement(UIView.make(backgroundColor: .blue))
            BoxHStack {
              BoxElement { UILabel.make(text: "@Muukii") }
              BoxHSpacer()
              BoxElement { UILabel.make(text: "@Muukii") }
            }
          }
          }
          .frame(width: 200, height: nil)
      }
    }
    
    root.update()
    
    view.addSubview(root)
    root.frame = view.bounds
    root.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
}
