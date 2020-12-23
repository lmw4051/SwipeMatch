//
//  Firebase+Utils.swift
//  SwipeMatch
//
//  Created by David on 2020/12/23.
//  Copyright © 2020 David. All rights reserved.
//

import Firebase

extension Firestore {
  func fetchCurrentUser(completion: @escaping (User?, Error?) -> ()) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
      if let err = err {
        completion(nil, err)
        return
      }
      
      guard let dictionary = snapshot?.data() else { return }
      let user = User(dictionary: dictionary)
      completion(user, nil)
    }
  }
}
