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
  
  let registerButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Register", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .heavy)
    button.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1)
    button.heightAnchor.constraint(equalToConstant: 44).isActive = true
    button.layer.cornerRadius = 22
    return button
  }()
  
  lazy var verticalStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [
      fullNameTextField,
      emailTextField,
      passwordTextField,
      registerButton
    ])
    sv.axis = .vertical
    sv.distribution = .fillEqually
    sv.spacing = 8
    return sv
  }()
  
  lazy var overallStackView = UIStackView(arrangedSubviews: [
    selectPhotoButton,
    verticalStackView
  ])
  
  fileprivate let gradientLayer = CAGradientLayer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupGradientLayer()
    setupLayout()
    setupNotificationObservers()
    setupTapGesture()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // Need to remove observer, otherwise will lead to Retain Cycle
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    gradientLayer.frame = view.bounds
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    if self.traitCollection.verticalSizeClass == .compact {
      overallStackView.axis = .horizontal
    } else {
      overallStackView.axis = .vertical
    }
  }
  
  // MARK: - Helper Methods
  fileprivate func setupGradientLayer() {
    let topColor = #colorLiteral(red: 0.9921568627, green: 0.3568627451, blue: 0.2156862745, alpha: 1)
    let bottomColor = #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1)
    
    // make sure to user cgColor
    gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    gradientLayer.locations = [0, 1]
    view.layer.addSublayer(gradientLayer)
    gradientLayer.frame = view.bounds
  }
  
  fileprivate func setupLayout() {
    view.addSubview(overallStackView)
    
    selectPhotoButton.widthAnchor.constraint(equalToConstant: 275).isActive = true
    
    overallStackView.axis = .vertical
    overallStackView.spacing = 8
    overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
    overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
  
  fileprivate func setupNotificationObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  fileprivate func setupTapGesture() {
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
  }
  
  // MARK: - Selector Methods
  @objc fileprivate func handleKeyboardShow(notification: Notification) {
    print(notification)
    guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    let keyboardFrame = value.cgRectValue
    print(keyboardFrame)
    
    // How tall the gap is from the register button to the bottom of the screen
    let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height
    print(bottomSpace)
    
    let difference = keyboardFrame.height - bottomSpace
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    })
  }
  
  @objc fileprivate func handleKeyboardHide() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.transform = .identity
    })
  }
  
  @objc fileprivate func handleTapDismiss() {
    self.view.endEditing(true)
  }
}
