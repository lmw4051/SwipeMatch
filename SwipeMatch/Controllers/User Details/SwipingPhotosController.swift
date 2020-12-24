//
//  SwipingPhotosController.swift
//  SwipeMatch
//
//  Created by David on 2020/12/24.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class SwipingPhotosController: UIPageViewController {
  // MARK: - Instance Properties
  var cardViewModel: CardViewModel! {
    didSet {
      print(cardViewModel.attributedString)
      controllers = cardViewModel.imageUrls.map({ imageUrl -> UIViewController in
        let photoController = PhotoController(imageUrl: imageUrl)
        return photoController
      })
      setViewControllers([controllers.first!], direction: .forward, animated: false)
      
      setupBarViews()
    }
  }
  
  var controllers = [UIViewController]()
  fileprivate let barsStackView = UIStackView(arrangedSubviews: [])
  fileprivate let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
  
  fileprivate let isCardViewMode: Bool
  
  // MARK: - View Life Cycles
  init(isCardViewMode: Bool = false) {
    self.isCardViewMode = isCardViewMode
    super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = self
    delegate = self
    view.backgroundColor = .white
    
    if isCardViewMode {
      disableSwipingAbility()
    }
    
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    
//    setViewControllers([controllers.first!], direction: .forward, animated: false)
  }
  
  // MARK: - Selector Methods
  @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
    print("handleTap")
    let currentController = viewControllers!.first!
    if let index = controllers.firstIndex(of: currentController) {
      
      barsStackView.arrangedSubviews.forEach({ $0.backgroundColor = deselectedBarColor })
      
      if gesture.location(in: self.view).x > view.frame.width / 2 {
        let nextIndex = min(index + 1, controllers.count - 1)
        let nextController = controllers[nextIndex]
        setViewControllers([nextController], direction: .forward, animated: false)
                
        barsStackView.arrangedSubviews[nextIndex].backgroundColor = .white
      } else {
        let prevIndex = max(0, index - 1)
        let prevController = controllers[prevIndex]
        setViewControllers([prevController], direction: .forward, animated: false)
                
        barsStackView.arrangedSubviews[prevIndex].backgroundColor = .white
      }
    }
  }
  
  // MARK: - Helper Methods
  fileprivate func setupBarViews() {
    cardViewModel.imageUrls.forEach { _ in
      let barView = UIView()
      barView.backgroundColor = deselectedBarColor
      barView.layer.cornerRadius = 2
      barsStackView.addArrangedSubview(barView)
    }
    
    barsStackView.arrangedSubviews.first?.backgroundColor = .white
    barsStackView.spacing = 4
    barsStackView.distribution = .fillEqually
    
    view.addSubview(barsStackView)
    
    var paddingTop: CGFloat = 8
    
    if !isCardViewMode {
      paddingTop += UIApplication.shared.statusBarFrame.height
    }
    
    barsStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: paddingTop, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
  }
  
  fileprivate func disableSwipingAbility() {
    view.subviews.forEach { v in
      if let v = v as? UIScrollView {
        v.isScrollEnabled = false
      }
    }
  }
}

// MARK: - UIPageViewControllerDataSource Methods
extension SwipingPhotosController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    let index = self.controllers.firstIndex(where: { $0 == viewController }) ?? 0
    if index == controllers.count - 1 { return nil }
    return controllers[index + 1]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
    if index == 0 { return nil }
    return controllers[index - 1]
  }
}

// MARK: - UIPageViewControllerDelegate Methods
extension SwipingPhotosController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    let currentPhotoController = viewControllers?.first
    if let index = controllers.firstIndex(where: { $0 == currentPhotoController }) {
      barsStackView.arrangedSubviews.forEach({ $0.backgroundColor = deselectedBarColor })
      barsStackView.arrangedSubviews[index].backgroundColor = .white
    }
  }
}
