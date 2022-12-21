//
//  ImageCell.swift
//  SpaceTest
//  Created by Дмитрий Помин on 10.07.2022.
//

import Kingfisher
import UIKit

final class ImageCell: UICollectionViewCell {

  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var title: UILabel!
  @IBOutlet private var settingButton: UIView!
  @IBOutlet private var roundView: UIView!

  var buttonPressed: (() -> Void)?

  @IBAction
  private func buttonClick(_ sender: UIButton) {
    buttonPressed?()
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    roundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    roundView.layer.cornerRadius = 25
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.kf.cancelDownloadTask()
  }

  func configure(image: URL, title: String) {
    self.title.text = title
    imageView.kf.setImage(with: image)
  }
}
