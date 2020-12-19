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
  
  // Configurations
  fileprivate let threshold: CGFloat = 80
  
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
      handleEnded(gesture)
    default:
      ()
    }
  }
  
  // MARK: - Helper Methods
  fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: nil)
    // rotation
    // convert radians to degrees
    let degrees: CGFloat = translation.x / 20
    let angle = degrees * .pi / 180
    
    let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
    self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
  }
  
  fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
    let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
    let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold
    
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
      if shouldDismissCard {
        self.frame = CGRect(x: 1000 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
      } else {
        self.transform = .identity
      }
    }) { _ in
      self.transform = .identity
      self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.width, height: self.superview!.frame.height)
    }
  }
}
