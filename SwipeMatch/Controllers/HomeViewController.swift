//
//  ViewController.swift
//  SwipeMatch
//
//  Created by David on 2020/12/19.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

  // MARK: - Instance Properties
  let topStackView = TopNavigationStackView()
  let cardsDeckView = UIView()
  let buttonsStackView = HomeBottomControlsStackView()
  
  let cardViewModels: [CardViewModel] = {
    let producers = [
      User(name: "Kelly", age: 23, profession: "Music DJ", imageNames: ["kelly1", "kelly2", "kelly3"]),
      User(name: "Jane", age: 18, profession: "Teacher", imageNames: ["lady4c"]),
      Advertiser(title: "Slide Out Menu", brandName: "Lets Build Thta App", posterPhotoName: "slide_out_menu_poster"),
      User(name: "Jane", age: 18, profession: "Teacher", imageNames: ["jane1", "jane2", "jane3"]),
    ] as [ProducesCardViewModel]
    
    let viewModels = producers.map { return $0.toCardViewModel() }
    return viewModels
  }()

  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
    
    setupLayout()
    setupDummyCards()
  }
  
  // MARK: - Selector Methods
  @objc func handleSettings() {
    print("handleSettings")
    let registraitonController = RegistrationController()
    present(registraitonController, animated: true)
  }
  
  // MARK: - Helper Methods
  fileprivate func setupLayout() {
    let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonsStackView])
    overallStackView.axis = .vertical
    view.addSubview(overallStackView)
    overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    overallStackView.isLayoutMarginsRelativeArrangement = true
    overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
    
    overallStackView.bringSubviewToFront(cardsDeckView)
  }
  
  fileprivate func setupDummyCards() {
    cardViewModels.forEach { cardVM in
      let cardView = CardView(frame: .zero)
      cardView.cardViewModel = cardVM      
      cardsDeckView.addSubview(cardView)
      cardView.fillSuperview()
    }
  }
}
