//
//  CardViewModel.swift
//  SwipeMatch
//
//  Created by David on 2020/12/19.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

protocol ProducesCardViewModel {
  func toCardViewModel() -> CardViewModel
}

// View Model is suppored to represent the State of our views
class CardViewModel {
  // Define the properties that are view will display/render out
  let imageNames: [String]
  let attributedString: NSAttributedString
  let textAlignment: NSTextAlignment
  
  fileprivate var imageIndex = 0 {
    didSet {
      let imageName = imageNames[imageIndex]
      let image = UIImage(named: imageName)
      imageIndexObserver?(imageIndex, image)
    }
  }
  
  init(imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
    self.imageNames = imageNames
    self.attributedString = attributedString
    self.textAlignment = textAlignment
  }
  
  // Reactive Programming
  var imageIndexObserver: ((Int, UIImage?) ->())?
  
  func advanceToNextPhoto() {
    imageIndex = min(imageIndex + 1, imageNames.count - 1)
  }
  
  func goToPreviousPhoto() {
    imageIndex = max(0, imageIndex - 1)
  }
}
