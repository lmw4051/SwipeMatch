//
//  HomeBottomControlsStackView.swift
//  SwipeMatch
//
//  Created by David on 2020/12/19.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {
  // MARK: - Instance Properties
  let refreshButton = createButton(image: #imageLiteral(resourceName: "refresh_circle"))
  let dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"))
  let superLikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"))
  let likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"))
  let specialButton = createButton(image: #imageLiteral(resourceName: "boost_circle"))
  
  // MARK: - View Life Cycles
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    distribution = .fillEqually
    heightAnchor.constraint(equalToConstant: 100).isActive = true
    
    [refreshButton, dislikeButton, superLikeButton, likeButton, specialButton].forEach { button in
      self.addArrangedSubview(button)
    }
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Helper Methods
  static func createButton(image: UIImage) -> UIButton {
    let button = UIButton(type: .system)
    button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
    button.imageView?.contentMode = .scaleAspectFill
    return button
  }
}
