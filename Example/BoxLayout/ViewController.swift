//
//  ViewController.swift
//  BoxLayout
//
//  Created by Muukii on 06/19/2019.
//  Copyright (c) 2019 Muukii. All rights reserved.
//

import UIKit

import BoxLayout

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let label1 = UILabel()
    let label2 = UILabel()
    let label3 = UILabel()
    
    label1.text = "ABC"
    label2.text = "ABC"
    label3.text = "ABC"
    
    #if swift(>=5.1)
    
    let root: UIView = BoxContainerView {
      BoxPadding(padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)) {
        BoxVStack {
          BoxHStack {
            
            BoxVStack {
              BoxElement(UILabel.make(text: "Muukii"))
              BoxElement(UILabel.make(text: "Camera/Photo"))
              BoxElement(UILabel.make(text: "Software Engineer / Tokyo"))
              BoxElement(UILabel.make(text: "Leica, Fujifilm"))
            }
            
            BoxHSpacer()
            
            BoxVStack {
              BoxElement(UIView.make(backgroundColor: .yellow))
                .frame(width: 64, height: 64)
            }
          }
          
          BoxVStack {
            BoxElement(UIView.make(backgroundColor: .cyan))
              .frame(width: 64, height: 64)
            BoxElement(UIView())
              .frame(width: 36)
            BoxHStack {
              BoxElement(UIView.make(backgroundColor: .red))
                .frame(width: 64, height: 64)
              BoxElement(UIView.make(backgroundColor: .orange))
                .frame(width: 64, height: 64)
              BoxElement(UIView.make(backgroundColor: .green))
                .frame(width: 64, height: 64)
            }
            
          }
          
          BoxVSpacer()
          
          BoxZStack {
            BoxElement(UIView.make(backgroundColor: .purple))
              .frame(width: 200, height: 200)
            BoxInset(insets: UIEdgeInsets.init(top: CGFloat.infinity, left: 20.0, bottom: 20, right: .infinity)) {
              BoxElement(UILabel.make(text: "Helloooooooooooooooooooooooooooooooooooooooooooo"))
            }
          }
        }
      }
      
    }
    
    view.addSubview(root)
    root.frame = view.bounds
    root.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    #endif
  }
}

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
