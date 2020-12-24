//
//  CardView.swift
//  SwipeMatch
//
//  Created by David on 2020/12/19.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import SDWebImage

protocol CardViewDelegate {
  func didTapMoreInfo(cardViewModel: CardViewModel)
}

class CardView: UIView {
  // MARK: - Instance Properties
  var delegate: CardViewDelegate?
  
  var cardViewModel: CardViewModel! {
    didSet {
      // accessing index 0 will crash if imageNames.count == 0
//      let imageName = cardViewModel.imageUrls.first ?? ""
      
//      if let url = URL(string: imageName) {
//        imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "photo_placeholder"), options: .continueInBackground)
//      }
      
      swipingPhotosController.cardViewModel = self.cardViewModel
      
      informationLabel.attributedText = cardViewModel.attributedString
      informationLabel.textAlignment = cardViewModel.textAlignment
      
      (0..<cardViewModel.imageUrls.count).forEach { _ in
        let barView = UIView()
        barView.backgroundColor = barDeselectedcolor
        barsStackView.addArrangedSubview(barView)
      }
      barsStackView.arrangedSubviews.first?.backgroundColor = .white
      
      setupImageIndexObserver()
    }
  }
  
  fileprivate let moreInfoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
    button.addTarget(self, action: #selector(handleMoreInfo), for: .touchUpInside)
    return button
  }()
  
//  fileprivate let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
  fileprivate let swipingPhotosController = SwipingPhotosController(isCardViewMode: true)
  fileprivate let gradientLayer = CAGradientLayer()
  fileprivate let informationLabel = UILabel()
  
  // Configurations
  fileprivate let threshold: CGFloat = 80
  fileprivate let barsStackView = UIStackView()
  fileprivate let barDeselectedcolor = UIColor(white: 0, alpha: 0.1)
  
  // MARK: - View Life Cycles
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupLayout()
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    addGestureRecognizer(panGesture)
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Selector Methods
  @objc func handlePan(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .began:
      superview?.subviews.forEach({ subview in
        subview.layer.removeAllAnimations()
      })
    case .changed:
      handleChanged(gesture)
    case .ended:
      handleEnded(gesture)
    default:
      ()
    }
  }
  
  @objc func handleTap(gesture: UITapGestureRecognizer) {
    let tapLocation = gesture.location(in: nil)
    let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
    
    if shouldAdvanceNextPhoto {
      cardViewModel.advanceToNextPhoto()
    } else {
      cardViewModel.goToPreviousPhoto()
    }    
  }
  
  @objc fileprivate func handleMoreInfo() {    
    delegate?.didTapMoreInfo(cardViewModel: self.cardViewModel)
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
    
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
      if shouldDismissCard {
        self.frame = CGRect(x: 600 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
      } else {
        self.transform = .identity
      }
    }) { _ in
      self.transform = .identity
      
      if shouldDismissCard {
        self.removeFromSuperview()
      }
    }
  }
  
  fileprivate func setupLayout() {
    layer.cornerRadius = 10
    clipsToBounds = true
    
    let swipingPhotosView = swipingPhotosController.view!
    addSubview(swipingPhotosView)
    swipingPhotosView.fillSuperview()
    
//    setupBarsStackView()
    
    // add a gradient layer
    setupGradientLayer()
    
    addSubview(informationLabel)
    informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
    informationLabel.textColor = .white
    informationLabel.numberOfLines = 0
    
    addSubview(moreInfoButton)
    moreInfoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor , padding: .init(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
  }
  
  fileprivate func setupBarsStackView() {
    addSubview(barsStackView)
    barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    barsStackView.spacing = 4
    barsStackView.distribution = .fillEqually
  }
  
  fileprivate func setupGradientLayer() {
    // draw a gradient with swift
    gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
    gradientLayer.locations = [0.5, 1.1]
    
    // self.frame is actually zero frame in here
    layer.addSublayer(gradientLayer)
  }
  
  override func layoutSubviews() {
    // The CardFrame data will be get here
    gradientLayer.frame = self.frame
  }
  
  fileprivate func setupImageIndexObserver() {
    cardViewModel.imageIndexObserver = { [weak self] (idx ,imageUrl) in
      print("setupImageIndexObserver")
      guard let self = self else { return }
//      if let url = URL(string: imageUrl ?? "") {
//        self.imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "photo_placeholder"), options: .continueInBackground)
//      }
      
      self.barsStackView.arrangedSubviews.forEach { v in
        v.backgroundColor = self.barDeselectedcolor
      }
      self.barsStackView.arrangedSubviews[idx].backgroundColor = .white
    }
  }
}
