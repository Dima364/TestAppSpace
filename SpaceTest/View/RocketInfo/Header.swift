//
//  Header.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 05.12.2022.
//

import UIKit

class Header: UICollectionReusableView {

  @IBOutlet private var titleLabel: UILabel!

  func configure(withTitle title: String?) {
    titleLabel.text = title
  }
}
