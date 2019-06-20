//
//  UpdateViewController.swift
//  BoxLayout_Example
//
//  Created by muukii on 2019/06/20.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

import BoxLayout

final class UpdateViewController : UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let label1 = UILabel()
    let label2 = UILabel()
    let label3 = UILabel()
    
    label1.text = "ABC"
    label2.text = "ABC"
    label3.text = "ABC"
    
    #if swift(>=5.1)
    
    let root: BoxContainerView = BoxContainerView {
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
    
    root.update()
    
    view.addSubview(root)
    root.frame = view.bounds
    root.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    #endif
    
  }
}

