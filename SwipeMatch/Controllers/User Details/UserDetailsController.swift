//
//  UserDetailsController.swift
//  SwipeMatch
//
//  Created by David on 2020/12/24.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class UserDetailsController: UIViewController {
  // MARK: - Instance Properties
  var cardViewModel: CardViewModel! {
    didSet {
      infoLabel.attributedText = cardViewModel.attributedString
      swipingPhotosController.cardViewModel = cardViewModel
    }
  }
  
  lazy var scrollView: UIScrollView = {
    let sv = UIScrollView()    
    sv.alwaysBounceVertical = true
    sv.contentInsetAdjustmentBehavior = .never
    sv.delegate = self
    return sv
  }()
  
  let infoLabel: UILabel = {
    let label = UILabel()
    label.text = "User name 30\nDoctor\nSome bio text down below"
    label.numberOfLines = 0
    return label
  }()
  
  let dismissButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "dismiss_down_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
    button.addTarget(self, action: #selector(handleTapDismiss), for: .touchUpInside)
    return button
  }()
  
  lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
  lazy var superLikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleDislike))
  lazy var likeButton = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleDislike))
  
  let swipingPhotosController = SwipingPhotosController()
  
  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupLayout()
    setupVisualBlurEffectView()
    setupBottomControls()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let swipingView = swipingPhotosController.view!
    swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
  }
  
  // MARK: - Helper Methods
  fileprivate func setupLayout() {
    view.addSubview(scrollView)
    scrollView.fillSuperview()
    
    let swipingView = swipingPhotosController.view!
    scrollView.addSubview(swipingView)
    
    scrollView.addSubview(infoLabel)
    infoLabel.anchor(top: swipingView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
    
    scrollView.addSubview(dismissButton)
    dismissButton.anchor(top: swipingView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 24), size: .init(width: 50, height: 50))
  }
  
  fileprivate func setupBottomControls() {
    let stackView = UIStackView(arrangedSubviews: [
      dislikeButton, superLikeButton, likeButton
    ])
    stackView.distribution = .fillEqually
    stackView.spacing = -32
    view.addSubview(stackView)
    stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
    stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
  }
        
  fileprivate func setupVisualBlurEffectView() {
    let blurEffect = UIBlurEffect(style: .regular)
    let visualEffectView = UIVisualEffectView(effect: blurEffect)
    
    view.addSubview(visualEffectView)
    visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
  }
  
  fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
    let button = UIButton(type: .system)
    button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
    button.addTarget(self, action: selector, for: .touchUpInside)
    return button
  }
  
  fileprivate let extraSwipingHeight: CGFloat = 80
  
  // MARK: - Selector Methods
  @objc fileprivate func handleTapDismiss() {
    self.dismiss(animated: true)
  }
  
  @objc fileprivate func handleDislike() {
    print("handleDislike")
  }
}

// MARK: - UIScrollViewDelegate Methods
extension UserDetailsController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let changeY = -scrollView.contentOffset.y
    print(changeY)
    
    var width = view.frame.width + changeY * 2
    width = max(view.frame.width, width)
    
    let imageView = swipingPhotosController.view!
    imageView.frame = CGRect(x: min(0,-changeY), y: min(0, -changeY), width: width, height: width + extraSwipingHeight)
  }
}
