//
//  InfoCell.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 21.10.2022.
//

import UIKit

final class InfoCell: UICollectionViewCell {

  @IBOutlet private var value: UILabel!
  @IBOutlet private var hint: UILabel!

  func configure(value: String, hint: String) {
    self.value.text = value
    self.hint.text = hint
  }
}
