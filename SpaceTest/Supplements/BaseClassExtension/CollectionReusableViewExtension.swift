//
//  CollectionReusableViewExtension.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 20.12.2022.
//

import UIKit

extension UICollectionReusableView {
  static var reuseIdentifier: String {
    String(describing: self)
  }
}
