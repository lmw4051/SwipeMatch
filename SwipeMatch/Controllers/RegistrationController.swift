//
//  RegistrationController.swift
//  SwipeMatch
//
//  Created by David on 2020/12/20.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class RegistrationController: UIViewController {
  let selectPhotoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Select Photo", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 32, weight: .heavy)
    button.backgroundColor = .white
    button.setTitleColor(.black, for: .normal)
    button.heightAnchor.constraint(equalToConstant: 275).isActive = true
    button.layer.cornerRadius = 16
    return button
  }()
  
  let fullNameTextField: CustomTextField = {
    let tf = CustomTextField(padding: 24)
    tf.placeholder = "Enter full name"
    tf.backgroundColor = .white
    return tf
  }()
  
  let emailTextField: CustomTextField = {
    let tf = CustomTextField(padding: 24)
    tf.placeholder = "Enter email"
    tf.keyboardType = .emailAddress
    tf.backgroundColor = .white
    return tf
  }()
  
  let passwordTextField: CustomTextField = {
    let tf = CustomTextField(padding: 24)
    tf.placeholder = "Enter password"
    tf.isSecureTextEntry = true
    tf.backgroundColor = .white
    return tf
  }()    
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupGradientLayer()
    
    view.backgroundColor = .red
    let stackView = UIStackView(arrangedSubviews: [
      selectPhotoButton,
      fullNameTextField,
      emailTextField,
      passwordTextField
    ])
    view.addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 8
    stackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
    stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
  
  fileprivate func setupGradientLayer() {
    let gradientLayer = CAGradientLayer()
    let topColor = #colorLiteral(red: 0.9921568627, green: 0.3568627451, blue: 0.2156862745, alpha: 1)
    let bottomColor = #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1)
    
    // make sure to user cgColor
    gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    gradientLayer.locations = [0, 1]
    view.layer.addSublayer(gradientLayer)
    gradientLayer.frame = view.bounds
  }
}
