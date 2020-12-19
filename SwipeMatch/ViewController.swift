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
  let buttonsStackView = HomeBottomControlsStackView()
  let blueView = UIView()

  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    blueView.backgroundColor = .blue
    
    setupLayout()
  }
  
  // MARK: - Helper Methods
  fileprivate func setupLayout() {
    let overallStackView = UIStackView(arrangedSubviews: [topStackView, blueView, buttonsStackView])
    overallStackView.axis = .vertical
    view.addSubview(overallStackView)
    overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
  }
}
