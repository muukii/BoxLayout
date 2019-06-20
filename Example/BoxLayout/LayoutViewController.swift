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
  
  private let top = UIView.make(backgroundColor: .red)
  private let section = UIView.make(backgroundColor: .orange)
  private let name = UILabel.make(text: "@Muukii")
  private let bg = UIView.make(backgroundColor: .blue)
  private let age = UILabel.make(text: "28")

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let root = BoxContainerView {
      BoxCenter {
        BoxVStack {
          BoxElement { self.top }
            .aspectRatio(ratio: CGSize(width: 1, height: 1))
          BoxElement { self.section }
            .aspectRatio(ratio: CGSize(width: 1, height: 0.2))
          BoxZStack {
            BoxElement { self.bg }
            BoxHStack {
              BoxElement { self.name }
              BoxHSpacer()
              BoxElement { self.age }
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
