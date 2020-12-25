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
  
  var swipes = [String: Int]()
  
  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
    bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
    bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
    
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
      
      self.fetchSwipes()
      
//      self.fetchUsersFromFirestore()
    }
  }
  
  fileprivate func fetchSwipes() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
      if let err = err {
        print("Failed to fetch swipes info for currently logged in user:", err)
        return
      }
      
      print("Swipes:", snapshot?.data() ?? "")
      guard let data = snapshot?.data() as? [String: Int] else { return }
      self.swipes = data
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
    
    // Fix bug after clicking save button, the like/dislike button no longer works
    topCardView = nil
    
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
        let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
        let hasNotSwipedBefore = self.swipes[user.uid!] == nil
        
        if isNotCurrentUser && hasNotSwipedBefore {
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
  
  fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
    let duration = 0.5
    let translationAnimation = CABasicAnimation(keyPath: "position.x")
    translationAnimation.toValue = translation
    translationAnimation.duration = duration
    translationAnimation.fillMode = .forwards
    translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
    translationAnimation.isRemovedOnCompletion = false
    
    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
    rotationAnimation.toValue = angle * CGFloat.pi / 180
    rotationAnimation.duration = duration
    
    let cardView = topCardView
    topCardView = cardView?.nextCardView
    
    CATransaction.setCompletionBlock {
      cardView?.removeFromSuperview()
    }
    
    cardView?.layer.add(translationAnimation, forKey: "translation")
    cardView?.layer.add(rotationAnimation, forKey: "rotation")
    
    CATransaction.commit()
  }
  
  fileprivate func saveSwipeToFirestore(didLike: Int) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let cardUID = topCardView?.cardViewModel.uid else { return }
    
    let documentData = [cardUID: didLike]
    
    Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
      if let err = err {
        print("Failed to fetch swipe document:", err)
        return
      }
      
      if snapshot?.exists == true {
        Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { err in
          if let err = err {
            print("Failed to save swipe data:", err)
            return
          }
          print("Successfully updated swipe...")
          self.checkIfMatchExists(cardUID: cardUID)
        }
      } else {
        Firestore.firestore().collection("swipes").document(uid).setData(documentData) { err in
          if let err = err {
            print("Failed to save swipe data:", err)
            return
          }
          print("Successfully saved swipe...")
          self.checkIfMatchExists(cardUID: cardUID)
        }
      }
    }
  }
  
  fileprivate func checkIfMatchExists(cardUID: String) {
    print("checkIfMatchExists")
    print("cardUID:", cardUID)
    
    Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
      if let err = err {
        print("Failed to fetch document for card user:", err)
        return
      }
      
      guard let data = snapshot?.data() else { return }
      print(data)
      
      guard let uid = Auth.auth().currentUser?.uid else { return }
      
      let hasMatched = data[uid] as? Int == 1
      
      if hasMatched {
        print("Has matched")
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Found a match"
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4)
      }
    }
  }
  
  // MARK: - Selector Methods
  @objc func handleSettings() {
    let settingsController = SettingsController()
    settingsController.delegate = self
    let navController = UINavigationController(rootViewController: settingsController)
    navController.modalPresentationStyle = .fullScreen
    present(navController, animated: true)
  }
  
  @objc func handleRefresh() {
    fetchUsersFromFirestore()
  }
  
  @objc func handleLike() {
    saveSwipeToFirestore(didLike: 1)
    performSwipeAnimation(translation: 700, angle: 15)
  }
  
  @objc func handleDislike() {
    saveSwipeToFirestore(didLike: 0)
    performSwipeAnimation(translation: -700, angle: -15)
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
