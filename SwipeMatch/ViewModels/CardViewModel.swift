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
  let uid: String
  let imageUrls: [String]
  let attributedString: NSAttributedString
  let textAlignment: NSTextAlignment
  
  fileprivate var imageIndex = 0 {
    didSet {
      let imageUrl = imageUrls[imageIndex]
//      let image = UIImage(named: imageName)
      imageIndexObserver?(imageIndex, imageUrl)
    }
  }
  
  init(uid: String, imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
    self.uid = uid
    self.imageUrls = imageNames
    self.attributedString = attributedString
    self.textAlignment = textAlignment
  }
  
  // Reactive Programming
  var imageIndexObserver: ((Int, String?) ->())?
  
  func advanceToNextPhoto() {
    imageIndex = min(imageIndex + 1, imageUrls.count - 1)
  }
  
  func goToPreviousPhoto() {
    imageIndex = max(0, imageIndex - 1)
  }
}
