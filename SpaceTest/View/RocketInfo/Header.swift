//
//  Header.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 05.12.2022.
//

import UIKit

final class Header: UICollectionReusableView {

  @IBOutlet private var titleLabel: UILabel!

  func configure(withTitle title: String?) {
    self.titleLabel.text = title
  }
}
