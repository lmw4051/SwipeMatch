//
//  ViewController.swift
//  SwipeMatch
//
//  Created by David on 2020/12/19.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // MARK: - Instance Properties
  let topStackView = TopNavigationStackView()
  let cardsDeckView = UIView()
  let buttonsStackView = HomeBottomControlsStackView()

  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()      
    setupLayout()
    setupDummyCards()
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
    print("setupDummyCards")
    let cardView = CardView(frame: .zero)
    cardsDeckView.addSubview(cardView)
    cardView.fillSuperview()
  }
}
