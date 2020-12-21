//
//  RegistrationViewModel.swift
//  SwipeMatch
//
//  Created by David on 2020/12/20.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
  var bindableImage = Bindable<UIImage>()
  var bindableIsFormValid = Bindable<Bool>()
  var bindableIsRegistering = Bindable<Bool>()
    
  var fullName: String? { didSet { checkFormValidity() } }
  var email: String? { didSet { checkFormValidity() } }
  var password: String? { didSet { checkFormValidity() } }
  
  fileprivate func checkFormValidity() {
    let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
    bindableIsFormValid.value = isFormValid    
  }
  
  func performRegistration(completion: @escaping (Error?) -> ()) {
    guard let email = email, let password = password else { return }
    bindableIsRegistering.value = true
    
    Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
      if let err = err {
        print(err)
        completion(err)
        return
      }
      
      print("Successfully registered user:", res?.user.uid ?? "")
      
      self.saveImageToFirebase(completion: completion)
    }
  }
  
  fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
    let fileName = UUID().uuidString
    let ref = Storage.storage( ).reference(withPath: "/images/\(fileName)")
    let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.5) ?? Data()
    ref.putData(imageData, metadata: nil) { (_, err) in
      if let err = err {
        completion(err)
        return
      }
      
      print("Finished uploading image to storage")
      ref.downloadURL { (url, err) in
        if let err = err {
          completion(err)
          return
        }
        
        self.bindableIsRegistering.value = false
        print("Download url of our image is:", url?.absoluteString ?? "")
        
        let imageUrl = url?.absoluteString ?? ""
        self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
      }
    }
  }
  
  fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
    let uid = Auth.auth().currentUser?.uid ?? ""
    let docData = ["fullName": fullName ?? "",
                   "uid": uid,
                   "imageUrl1": imageUrl]
    
    Firestore.firestore().collection("users").document(uid).setData(docData) { err in
      if let err = err {
        completion(err)
        return
      }
      
      completion(nil)
    }
  }
}
