//
//  SettingsCell.swift
//  SwipeMatch
//
//  Created by David on 2020/12/23.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
  class SettingsTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override var intrinsicContentSize: CGSize {
      return .init(width: 0, height: 44)
    }
  }
  
  let textField: UITextField = {
    let tf = SettingsTextField()
    tf.placeholder = "Enter Name"
    return tf
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(textField)
    textField.fillSuperview()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
