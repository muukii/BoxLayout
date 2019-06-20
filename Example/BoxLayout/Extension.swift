//
//  Extension.swift
//  BoxLayout_Example
//
//  Created by muukii on 2019/06/20.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

extension UIView {
  
  static func make(backgroundColor: UIColor) -> UIView {
    let view = UIView()
    view.backgroundColor = backgroundColor
    return view
  }
}

extension UILabel {
  
  static func make(text: String) -> UILabel {
    let label = UILabel()
    label.numberOfLines = 0
    label.text = text
    return label
  }
}
