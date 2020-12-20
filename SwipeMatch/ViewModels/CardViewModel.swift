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

struct CardViewModel {
  // Define the properties that are view will display/render out
  let imageNames: [String]
  let attributedString: NSAttributedString
  let textAlignment: NSTextAlignment
}
