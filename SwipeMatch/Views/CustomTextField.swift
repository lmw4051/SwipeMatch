//
//  CustomTextField.swift
//  SwipeMatch
//
//  Created by David on 2020/12/20.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
  // MARK: - Instance Properties
  let padding: CGFloat
  let height: CGFloat
  
  // MARK: - View Life Cycles
  init(padding: CGFloat, height: CGFloat) {
    self.padding = padding
    self.height = height
    super.init(frame: .zero)
    layer.cornerRadius = 25
    backgroundColor = .white
    textColor = .black
  }
      
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - 
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: padding, dy: 0)
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: padding, dy: 0)
  }
  
  override var intrinsicContentSize: CGSize {
    return .init(width: 0, height: 50)
  }
}
