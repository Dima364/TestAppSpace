//
//  LaunchesTableController.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 14.11.2022.
//

import UIKit

final class LaunchesTableController: UITableViewController {

  private var data: [RocketLaunch.Doc] = []
  private let networkService: NetworkService
  private let rocketId: String

  required init?(coder: NSCoder, rocketId: String, rocketName: String, networkService: NetworkService = NetworkService()) {
    self.rocketId = rocketId
    self.networkService = networkService
    super.init(coder: coder)
    self.title = rocketName
  }

  @available (*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:_ is not implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    getLaunchesList()
  }

  private func getLaunchesList() {
    networkService.getLaunches(forRocket: rocketId) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let launches):
          if launches.docs.isEmpty {
            self.presentAlert(withMessage: "Запусков не найдено")
          }
          self.data = launches.docs
          self.tableView.reloadData()
        case .failure(let error):
          self.presentAlert(withMessage: error.localizedDescription)
        }
      }
    }
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
    let imageName = data[indexPath.row].success ? "up" : "down"

    cell.configure(
      name: data[indexPath.row].name,
      date: Date.dateFormatterRu.string(from: data[indexPath.row].dateLocal),
      imageName: imageName
    )
    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    data.count
  }
}
