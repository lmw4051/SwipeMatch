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
  
  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
    bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    
    setupLayout()
    setupFirestoreUserCards()
    fetchUsersFromFirestore()
  }
  
  // MARK: - Selector Methods
  @objc func handleSettings() {
    print("handleSettings")
    let registraitonController = RegistrationController()
    present(registraitonController, animated: true)
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
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = "Fetching Users"
    hud.show(in: view)
    
    // Introduce pagination here to page through 2 users at a time
    let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)

    query.getDocuments { (snapshot, err) in
      hud.dismiss()
      
      if let err = err {
        print("Failed to fetch user:", err)
        return
      }
      
      snapshot?.documents.forEach({ documentSnapshot in
        let userDictionary = documentSnapshot.data()
        let user = User(dictionary: userDictionary)
        self.cardViewModels.append(user.toCardViewModel())
        self.lastFetchedUser = user
        self.setupCardFromUser(user: user)
      })
    }
  }
  
  fileprivate func setupCardFromUser(user: User) {
    let cardView = CardView(frame: .zero)
    cardView.cardViewModel = user.toCardViewModel()
    cardsDeckView.addSubview(cardView)
    cardsDeckView.sendSubviewToBack(cardView)
    cardView.fillSuperview()
  }
}
