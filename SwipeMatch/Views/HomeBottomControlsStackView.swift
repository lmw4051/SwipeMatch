//
//  HomeBottomControlsStackView.swift
//  SwipeMatch
//
//  Created by David on 2020/12/19.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    distribution = .fillEqually
    heightAnchor.constraint(equalToConstant: 100).isActive = true
    
    let subViews = [#imageLiteral(resourceName: "refresh_circle"), #imageLiteral(resourceName: "dismiss_circle"), #imageLiteral(resourceName: "super_like_circle"), #imageLiteral(resourceName: "like_circle"), #imageLiteral(resourceName: "boost_circle")].map { img -> UIView in
      let button = UIButton(type: .system)
      button.setImage(img.withRenderingMode(.alwaysOriginal), for: .normal)
      return button
    }
    
    subViews.forEach { v in
      addArrangedSubview(v)
    }    
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
