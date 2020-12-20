//
//  Bindable.swift
//  SwipeMatch
//
//  Created by David on 2020/12/20.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation

class Bindable<T> {
  var value: T? {
    didSet {
      observer?(value)
    }
  }
  
  var observer: ((T?) ->())?
  
  func bind(observer: @escaping (T?) -> ()) {
    self.observer = observer
  }
}
