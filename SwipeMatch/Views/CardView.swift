//
//  CardView.swift
//  SwipeMatch
//
//  Created by David on 2020/12/19.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class CardView: UIView {
  // MARK: - Instance Properties
  fileprivate let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
  
  // MARK: - View Life Cycles
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    layer.cornerRadius = 10
    clipsToBounds = true
    
    addSubview(imageView)
    imageView.fillSuperview()
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    addGestureRecognizer(panGesture)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Selector Methods
  @objc func handlePan(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .changed:
      handleChanged(gesture)
    case .ended:
      handleEnded()
    default:
      ()
    }
  }
  
  // MARK: - Helper Methods
  fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: nil)
    self.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
  }
  
  fileprivate func handleEnded() {
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
      self.transform = .identity
    }) { _ in
      
    }
  }
}
