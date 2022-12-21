//
//  SettingsCell.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 15.07.2022.
//

import UIKit

final class SettingsCell: UITableViewCell {

  @IBOutlet private var label: UILabel!
  @IBOutlet private var metricSegment: UISegmentedControl!
  var onChangeSetting: ((Int) -> Void)?

  @IBAction
  private func metricValueChanged(_ sender: UISegmentedControl) {
    onChangeSetting?(sender.selectedSegmentIndex)
  }

  func configure(hint: String, selectedIndex: Int, metrics: [String]) {
    metricSegment.removeAllSegments()
    for (index, symbol) in metrics.enumerated() {
      metricSegment.insertSegment(withTitle: symbol, at: index, animated: false)
    }

    label.text = hint
    metricSegment.selectedSegmentIndex = selectedIndex
  }
}
