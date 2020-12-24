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

class HomeViewController: UIViewController {
  // MARK: - Instance Properties
  let topStackView = TopNavigationStackView()
  let cardsDeckView = UIView()
  let bottomControls = HomeBottomControlsStackView()

  var cardViewModels = [CardViewModel]()
  
  var lastFetchedUser: User?
  
  fileprivate var user: User?
  fileprivate let hud = JGProgressHUD(style: .dark)
  
  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
    bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    
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
//    guard let minAge = user?.minSeekingAge,
//      let maxAge = user?.maxSeekingAge else { return }
    
//    let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
    
    let query = Firestore.firestore().collection("users")
    
    query.getDocuments { (snapshot, err) in
      self.hud.dismiss()
      
      if let err = err {
        print("Failed to fetch user:", err)
        return
      }
      
      snapshot?.documents.forEach({ documentSnapshot in
        let userDictionary = documentSnapshot.data()
        let user = User(dictionary: userDictionary)
        
        if user.uid != Auth.auth().currentUser?.uid {
          self.setupCardFromUser(user: user)
        }
        
//        self.cardViewModels.append(user.toCardViewModel())
//        self.lastFetchedUser = user
      })
    }
  }
  
  fileprivate func setupCardFromUser(user: User) {
    let cardView = CardView(frame: .zero)
    cardView.delegate = self
    cardView.cardViewModel = user.toCardViewModel()
    cardsDeckView.addSubview(cardView)
    cardsDeckView.sendSubviewToBack(cardView)
    cardView.fillSuperview()
  }
}

extension HomeViewController: SettingsControllerDelegate {
  func didSaveSettings() {
    fetchCurrentUser()
  }
}

extension HomeViewController: LoginControllerDelegate {
  func didFinishLoggingIn() {
    fetchCurrentUser()
  }
}

extension HomeViewController: CardViewDelegate {
  func didTapMoreInfo() {
    let userDetailsController = UserDetailsController()
    present(userDetailsController, animated: true)
  }
}
