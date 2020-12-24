//
//  PhotoController.swift
//  SwipeMatch
//
//  Created by David on 2020/12/24.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit

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
