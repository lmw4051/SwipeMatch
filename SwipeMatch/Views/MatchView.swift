//
//  MatchView.swift
//  SwipeMatch
//
//  Created by David on 2020/12/25.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class MatchView: UIView {
    
  // MARK: - Instance Properties
  let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
  
  fileprivate let currentUserImageView: UIImageView = {
    let iv = UIImageView(image: #imageLiteral(resourceName: "kelly1"))
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.layer.borderWidth = 2
    iv.layer.borderColor = UIColor.white.cgColor
    return iv
  }()
  
  fileprivate let cardUserImageView: UIImageView = {
    let iv = UIImageView(image: #imageLiteral(resourceName: "jane2"))
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.layer.borderWidth = 2
    iv.layer.borderColor = UIColor.white.cgColor
    return iv
  }()
  
  // MARK: - View Lifecycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupBlurView()
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Helper Methods
  fileprivate func setupBlurView() {
    visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    
    addSubview(visualEffectView)
    visualEffectView.fillSuperview()
    visualEffectView.alpha = 0
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.visualEffectView.alpha = 1
    }) { _ in
      
    }
  }
  
  fileprivate func setupLayout() {
    addSubview(currentUserImageView)
    addSubview(cardUserImageView)
    
    let imageWidth: CGFloat = 140
    
    currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: imageWidth, height: imageWidth))
    currentUserImageView.layer.cornerRadius = imageWidth / 2
    currentUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    
    cardUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: imageWidth, height: imageWidth))
    cardUserImageView.layer.cornerRadius = imageWidth / 2
    cardUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
  
  // MARK: - Selector Methods
  @objc fileprivate func handleTapDismiss() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.alpha = 0
    }) { _ in
      self.removeFromSuperview()
    }
  }
}
