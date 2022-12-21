//
//  LaunchesTableCell.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 14.11.2022.
//

import UIKit

final class LaunchesTableCell: UITableViewCell {

  @IBOutlet private var launchStatusImage: UIImageView!
  @IBOutlet private var panel: UIView!
  @IBOutlet private var launchName: UILabel!
  @IBOutlet private var launchDate: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    panel.layer.cornerRadius = 15
  }

  func configure(name: String, date: String, imageName: String) {
    launchName.text = name
    launchDate.text = date
    launchStatusImage.image = UIImage(named: imageName)
  }
}
