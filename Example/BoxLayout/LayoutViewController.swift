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
  
  private let myView = MyView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    myView.toggleView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    
    myView.update()
    
    view.addSubview(myView)
    myView.frame = view.bounds
    myView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  @objc private func valueChanged() {
    myView.flag = myView.toggleView.isOn
    UIView.animate(withDuration: 0.2) {
      self.myView.update()
      self.myView.layoutIfNeeded()
    }   
  }
}

final class MyView: BoxContainerView {
  
  let toggleView = UISwitch()
  var flag: Bool = false
  
  private let top = UIView.make(backgroundColor: .red)
  private let section = UIView.make(backgroundColor: .orange)
  private let name = UILabel.make(text: "@Muukii")
  private let bg = UIView.make(backgroundColor: .blue)
  private let age = UILabel.make(text: "28")
  
  override func boxLayoutThatFits() -> BoxType {
    
    BoxCenter {
        BoxElement { toggleView }
    }
    
//    BoxCenter {
//      BoxVStack {
//        BoxElement { toggleView }
//        BoxEmpty()
//          .frame(height: 20)
//        if flag {
//          BoxElement { top }
//            .aspectRatio(ratio: CGSize(width: 1, height: 1))
//        }
//        BoxElement { section }
//          .aspectRatio(ratio: CGSize(width: 1, height: 0.2))
//        BoxZStack {
//          BoxElement { bg }
//          BoxHStack {
//            BoxElement { name }
//            BoxHSpacer()
//            BoxElement { age }
//          }
//        }
//        }
//        .frame(width: 200, height: nil)
//    }
  }
}
