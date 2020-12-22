//
//  SettingsController.swift
//  SwipeMatch
//
//  Created by David on 2020/12/22.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class CustomImagePickerController: UIImagePickerController {
  var imageButton: UIButton?
}

class SettingsController: UITableViewController {
  // MARK: - Instance Properties
  // In order to use createButton helper method we need to declare as lazy var
  lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
  lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
  lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
  
  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationItems()
    tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    tableView.tableFooterView = UIView()
  }
  
  // MARK: - Helper Methods
  fileprivate func setupNavigationItems() {
    navigationItem.title = "Settings"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleCancel)),
      UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleCancel))
    ]
  }
  
  func createButton(selector: Selector) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle("Select Photo", for: .normal)
    button.backgroundColor = .white
    button.layer.cornerRadius = 8
    button.addTarget(self, action: selector, for: .touchUpInside)
    button.imageView?.contentMode = .scaleAspectFill
    return button
  }
  
  // MARK: - Selector Methods
  @objc fileprivate func handleCancel() {
    dismiss(animated: true, completion: nil)
  }
  
  @objc fileprivate func handleSelectPhoto(button: UIButton) {
    let imagePicker = CustomImagePickerController()
    imagePicker.delegate = self
    imagePicker.imageButton = button
    present(imagePicker, animated: true)
  }
}

extension SettingsController {
  // MARK: - UITableViewDelegate Methods
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = UIView()
    header.addSubview(image1Button)
    
    let padding: CGFloat = 16
    
    image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
    image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
    
    let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.spacing = padding
    
    header.addSubview(stackView)
    stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
    return header
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 300
  }
}

extension SettingsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let selectedImage = info[.originalImage] as? UIImage
    let imageButton = (picker as? CustomImagePickerController)?.imageButton
    imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
    dismiss(animated: true)
  }
}
