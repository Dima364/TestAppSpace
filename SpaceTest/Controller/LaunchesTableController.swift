//
//  LaunchesTableController.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 14.11.2022.
//

import UIKit

final class LaunchesTableController: UITableViewController {

  var presenter: LaunchesPresenterProtocol!

  deinit {
    print("launchesTableController deinit")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = presenter.rocketName
  }

  // MARK: - UITableViewDelegate
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    100
  }

  // MARK: - UITableViewDataSource
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = self.tableView.dequeueReusableCell(
      withIdentifier: "LaunchesTableCell",
      for: indexPath
    ) as? LaunchesTableCell else {
      return UITableViewCell()
    }

    let launch = presenter.launches[indexPath.row]

    cell.configure(
      name: launch.name,
      date: Date.dateFormatterRu.string(from: launch.dateLocal),
      imageName: launch.success ? "up" : "down"
    )

    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    presenter.launches.count
  }
}

extension LaunchesTableController: LaunchesTableControllerProtocol {
  func success() {
    tableView.reloadData()
  }

  func failure(withError error: Error) {
    presentAlert(withMessage: error.localizedDescription)
  }
}
