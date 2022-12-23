//
//  CustomCollectionViewCell.swift
//  SpaceTest
//  SwiftLint: disable identifier_name
//  Created by Дмитрий Помин on 30.06.2022.
//

import UIKit

final class HorizontalCell: UICollectionViewCell {

  @IBOutlet private var value: UILabel!
  @IBOutlet private var hint: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.cornerRadius = 30
  }

  func configure(value: String, hint: String) {
    self.value.text = value
    self.hint.text = hint
  }
}
