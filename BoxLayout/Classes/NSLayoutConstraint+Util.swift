//
//  NSLayoutConstraint+Util.swift
//  BoxLayout
//
//  Created by muukii on 2019/06/21.
//

import Foundation

extension NSLayoutConstraint {
  
  func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
    self.priority = priority
    return self
  }
  
}
