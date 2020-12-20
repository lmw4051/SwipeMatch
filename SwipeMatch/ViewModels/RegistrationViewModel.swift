//
//  RegistrationViewModel.swift
//  SwipeMatch
//
//  Created by David on 2020/12/20.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

class RegistrationViewModel {
  var bindableImage = Bindable<UIImage>()
    
  var fullName: String? {
    didSet { checkFormValidity() }
  }
  var email: String? {
    didSet { checkFormValidity() }
  }
  var password: String? {
    didSet { checkFormValidity() }
  }
  
  fileprivate func checkFormValidity() {
    let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
    bindableIsFormValid.value = isFormValid    
  }
  
  var bindableIsFormValid = Bindable<Bool>()
  
  // Reactive Programming
//  var isFormValidObserver: ((Bool) -> ())?
}
