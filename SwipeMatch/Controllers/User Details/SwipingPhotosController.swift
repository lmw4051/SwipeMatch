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
  
  // MARK: - View Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = self
    delegate = self
    view.backgroundColor = .white
    
//    setViewControllers([controllers.first!], direction: .forward, animated: false)
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
    barsStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 8), size: .init(width: 0, height: 4))
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

class PhotoController: UIViewController {
  let imageView = UIImageView(image: #imageLiteral(resourceName: "kelly1"))
  
  init(imageUrl: String) {
    if let url = URL(string: imageUrl) {
      imageView.sd_setImage(with: url)
    }
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(imageView)
    imageView.fillSuperview()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
  }
}
