//
//  ViewController.swift
//  SwipeMatch
//
//  Created by David on 2020/12/19.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController {
  // MARK: - Instance Properties
  let topStackView = TopNavigationStackView()
  let cardsDeckView = UIView()
  let bottomControls = HomeBottomControlsStackView()

  var cardViewModels = [CardViewModel]()
  
  var lastFetchedUser: User?
  
  fileprivate var user: User?
  fileprivate let hud = JGProgressHUD(style: .dark)
  
  var topCardView: CardView?
  
  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
    bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
    
    setupLayout()
    fetchCurrentUser()
    
//    setupFirestoreUserCards()
//    fetchUsersFromFirestore()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("HomeController viewDidAppear")
    
    if Auth.auth().currentUser == nil {
      let registrationController = RegistrationController()
      registrationController.delegate = self
      let navController = UINavigationController(rootViewController: registrationController)
      navController.modalPresentationStyle = .fullScreen
      present(navController, animated: true)
    }
  }
  
  // MARK: - Helper Methods
  fileprivate func fetchCurrentUser() {
    hud.textLabel.text = "Loading"
    hud.show(in: view)
    
    cardsDeckView.subviews.forEach { $0.removeFromSuperview() }
    
    Firestore.firestore().fetchCurrentUser { (user, err) in
      if let err = err {
        print("Failed to fetch user:", err)
        self.hud.dismiss()
        return
      }
      self.user = user
      self.fetchUsersFromFirestore()
    }
  }
  
  // MARK: - Helper Methods
  fileprivate func setupLayout() {
    view.backgroundColor = .white
    
    let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
    overallStackView.axis = .vertical
    view.addSubview(overallStackView)
    overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    overallStackView.isLayoutMarginsRelativeArrangement = true
    overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
    
    overallStackView.bringSubviewToFront(cardsDeckView)
  }
  
  fileprivate func setupFirestoreUserCards() {
    cardViewModels.forEach { cardVM in
      let cardView = CardView(frame: .zero)
      cardView.cardViewModel = cardVM      
      cardsDeckView.addSubview(cardView)
      cardView.fillSuperview()
    }
  }
  
  fileprivate func fetchUsersFromFirestore() {
    let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
    let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
    
    let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
    
    query.getDocuments { (snapshot, err) in
      self.hud.dismiss()
      
      if let err = err {
        print("Failed to fetch user:", err)
        return
      }
      
      var previousCardView: CardView?
      
      snapshot?.documents.forEach({ documentSnapshot in
        let userDictionary = documentSnapshot.data()
        let user = User(dictionary: userDictionary)
        
        if user.uid != Auth.auth().currentUser?.uid {
          let cardView = self.setupCardFromUser(user: user)
          
          previousCardView?.nextCardView = cardView
          previousCardView = cardView
          
          if self.topCardView == nil {
            self.topCardView = cardView
          }
        }
      })
    }
  }
  
  fileprivate func setupCardFromUser(user: User) -> CardView {
    let cardView = CardView(frame: .zero)
    cardView.delegate = self
    cardView.cardViewModel = user.toCardViewModel()
    cardsDeckView.addSubview(cardView)
    cardsDeckView.sendSubviewToBack(cardView)
    cardView.fillSuperview()
    return cardView
  }
  
  // MARK: - Selector Methods
  @objc func handleSettings() {
    let settingsController = SettingsController()
    settingsController.delegate = self
    let navController = UINavigationController(rootViewController: settingsController)
    navController.modalPresentationStyle = .fullScreen
    present(navController, animated: true)
  }
  
  @objc fileprivate func handleRefresh() {
    fetchUsersFromFirestore()
  }
  
  @objc fileprivate func handleLike() {
    print("handleLike")
            
    UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
      self.topCardView?.frame = CGRect(x: 600, y: 0, width: self.topCardView!.frame.width, height: self.topCardView!.frame.height)
      let angle = 15 * CGFloat.pi / 180
      self.topCardView?.transform = CGAffineTransform(rotationAngle: angle)
    }) { _ in
      self.topCardView?.removeFromSuperview()
      self.topCardView = self.topCardView?.nextCardView
    }
  }
}

// MARK: - SettingsControllerDelegate Methods
extension HomeController: SettingsControllerDelegate {
  func didSaveSettings() {
    fetchCurrentUser()
  }
}

// MARK: - LoginControllerDelegate Methods
extension HomeController: LoginControllerDelegate {
  func didFinishLoggingIn() {
    fetchCurrentUser()
  }
}

// MARK: - CardViewDelegate Methods
extension HomeController: CardViewDelegate {
  func didTapMoreInfo(cardViewModel: CardViewModel) {
    print("didTapMoreInfo:", cardViewModel.attributedString)
    let userDetailsController = UserDetailsController()
    userDetailsController.cardViewModel = cardViewModel
    userDetailsController.modalPresentationStyle = .fullScreen
    present(userDetailsController, animated: true)
  }
  
  func didRemoveCard(cardView: CardView) {
    self.topCardView?.removeFromSuperview()
    self.topCardView = self.topCardView?.nextCardView
  }
}