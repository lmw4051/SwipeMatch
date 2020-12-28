//
//  MatchView.swift
//  SwipeMatch
//
//  Created by David on 2020/12/25.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import Firebase

class MatchView: UIView {
    
  // MARK: - Instance Properties
  var currentUser: User!
  
  var cardUID: String! {
    didSet {
      let query = Firestore.firestore().collection("users")
      query.document(cardUID).getDocument { (snapshot, err) in
        if let err = err {
          print("Failed to fetch card user:", err)
          return
        }
        
        guard let dictionary = snapshot?.data() else { return }
        let user = User(dictionary: dictionary)
        guard let url = URL(string: user.imageUrl1 ?? "") else { return }
        self.cardUserImageView.sd_setImage(with: url)
        
        guard let currentUserImageUrl = URL(string: self.currentUser.imageUrl1 ?? "") else { return }
        self.currentUserImageView.sd_setImage(with: currentUserImageUrl) { (_, _, _, _) in
          self.setupAnimations()
        }
        
        // setup the description label text
        self.descriptionLabel.text = "You and \(user.name ?? "") have liked\neach other"
      }
    }
  }
  
  let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
  lazy var views = [
    itsAMatchImageView,
    descriptionLabel,
    currentUserImageView,
    cardUserImageView,
    sendMessageButton,
    keepSwipingButton
  ]
  
  fileprivate let itsAMatchImageView: UIImageView = {
    let iv = UIImageView(image: #imageLiteral(resourceName: "itsamatch"))
    iv.contentMode = .scaleAspectFill
    return iv
  }()
  
  fileprivate let descriptionLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.textColor = .white
    label.font = .systemFont(ofSize: 20)
    label.numberOfLines = 0
    return label
  }()
  
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
  
  fileprivate let sendMessageButton: UIButton = {
    let button = SendMessageButton(type: .system)
    button.setTitle("SEND MESSAGE", for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  fileprivate let keepSwipingButton: UIButton = {
    let button = KeepSwipingButton(type: .system)
    button.setTitle("Keep Swiping", for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  // MARK: - View Lifecycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupBlurView()
    setupLayout()
//    setupAnimations()
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
    views.forEach { v in
      addSubview(v)
      v.alpha = 0
    }
    
//    addSubview(itsAMatchImageView)
//    addSubview(descriptionLabel)
//    addSubview(currentUserImageView)
//    addSubview(cardUserImageView)
//    addSubview(sendMessageButton)
//    addSubview(keepSwipingButton)
    
    let imageWidth: CGFloat = 140
    
    itsAMatchImageView.anchor(top: nil, leading: nil, bottom: descriptionLabel.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 300, height: 80))
    itsAMatchImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    
    descriptionLabel.anchor(top: nil, leading: leadingAnchor, bottom: currentUserImageView.topAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 50))
    
    currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: imageWidth, height: imageWidth))
    currentUserImageView.layer.cornerRadius = imageWidth / 2
    currentUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    
    cardUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: imageWidth, height: imageWidth))
    cardUserImageView.layer.cornerRadius = imageWidth / 2
    cardUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    
    sendMessageButton.anchor(top: currentUserImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 32, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))
    
    keepSwipingButton.anchor(top: sendMessageButton.bottomAnchor, leading: sendMessageButton.leadingAnchor, bottom: nil, trailing: sendMessageButton.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 60))
  }
  
  fileprivate func setupAnimations() {
    views.forEach({ $0.alpha = 1 })
    
    // Starting Positions
    let angle = 30 * CGFloat.pi / 180
    
    currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
    cardUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
    
    sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
    keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)
    
    // Keyframe animations for segmented animation
    UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: .calculationModeCubic, animations: {
      // Animation 1 - translation back to original position
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
        self.currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
        self.cardUserImageView.transform = CGAffineTransform(rotationAngle: angle)
      }
      
      // Animation 2 - rotation
      UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
        self.currentUserImageView.transform = .identity
        self.cardUserImageView.transform = .identity
      }
    }) { _ in
      
    }
    
    UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
      self.sendMessageButton.transform = .identity
      self.keepSwipingButton.transform = .identity
    })
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