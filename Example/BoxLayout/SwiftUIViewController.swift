//
//  SwiftUIViewController.swift
//  BoxLayout_Example
//
//  Created by muukii on 2019/06/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

import SwiftUI

@available(iOS 13, *)
final class SwiftUIViewController : UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let controller = UIHostingController(rootView: RootView())
    addChild(controller)
    view.addSubview(controller.view)
    controller.view.frame = view.bounds
    controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
}

@available(iOS 13, *)
struct RootView: View {

  var body: some View {
    
    VStack {
      
      Color.orange
        .frame(width: 30, height: 30)
      
      EmptyView()
        .frame(height: 30)
      
      Color.orange
        .frame(width: 30, height: 30)
      
    }
  
  }
}
