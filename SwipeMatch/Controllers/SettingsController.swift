//
//  SettingsController.swift
//  SwipeMatch
//
//  Created by David on 2020/12/22.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

class CustomImagePickerController: UIImagePickerController {
  var imageButton: UIButton?
}

class HeaderLabel: UILabel {
  override func drawText(in rect: CGRect) {
    super.drawText(in: rect.insetBy(dx: 16, dy: 0))
  }
}

class SettingsController: UITableViewController {
  // MARK: - Instance Properties
  // In order to use createButton helper method we need to declare as lazy var
  lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
  lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
  lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
  
  // Need to be declared as lazy var, otherwise there will be an error
  lazy var header: UIView = {
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
  }()
  
  var user: User?
  
  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationItems()
    tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    tableView.tableFooterView = UIView()
    tableView.keyboardDismissMode = .interactive
    
    fetchCurrentUser()
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
  
  fileprivate func fetchCurrentUser() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
      if let err = err {
        print(err)
        return
      }
      
      guard let dictionary = snapshot?.data() else { return }
      self.user = User(dictionary: dictionary)
      self.loadUserPhotos()
      self.tableView.reloadData()
    }
  }
  
  fileprivate func loadUserPhotos() {
    guard let imageUrl = user?.imageUrl1,
      let url = URL(string: imageUrl) else { return }
    SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
      self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
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
    if section == 0 {
      return header
    }
    
    let headerLabel = HeaderLabel()
    
    switch section {
    case 1:
      headerLabel.text = "Name"
    case 2:
      headerLabel.text = "Profession"
    case 3:
      headerLabel.text = "Age"
    default:
      headerLabel.text = "Bio"
    }
    return headerLabel
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 300
    }
    return 40
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 5
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 0 : 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = SettingsCell(style: .default, reuseIdentifier: nil)
    
    switch indexPath.section {
    case 1:
      cell.textField.placeholder = "Enter Name"
      cell.textField.text = user?.name
    case 2:
      cell.textField.placeholder = "Enter Profession"
      cell.textField.text = user?.profession
    case 3:
      cell.textField.placeholder = "Enter Age"
      
      if let age = user?.age {
        cell.textField.text = String(age)
      }
    default:
      cell.textField.placeholder = "Enter Bio"
    }
    
    return cell
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
