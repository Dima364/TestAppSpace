//
//  ButtonCell.swift
//  SpaceTest
//  Created by Дмитрий Помин on 20.07.2022.
//

import UIKit

final class ButtonCell: UICollectionViewCell {

  @IBOutlet private var button: UIButton!
  var openLaunchesController: (() -> Void)?

  override func awakeFromNib() {
    super.awakeFromNib()
    button.setTitleColor(.white, for: .normal)
    button.setTitle("Посмотреть запуски", for: .normal)
  }

  @IBAction
  private func buttonClick(_ sender: Any) {
    openLaunchesController?()
  }
}
