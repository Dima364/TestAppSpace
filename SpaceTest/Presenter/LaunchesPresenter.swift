//
//  LaunchesPresenter.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 14.01.2023.
//

import Foundation

protocol LaunchesTableControllerProtocol: AnyObject {
  func success(with launches: [LaunchItem])
  func failure(with error: Error)
}

protocol LaunchesPresenterProtocol: AnyObject {
  var view: LaunchesTableControllerProtocol? { get set }
  var rocketName: String { get }
  func getLaunches()
}

final class LaunchesPresenter: LaunchesPresenterProtocol {
  private let rocketId: String
  private let networkService: NetworkServiceProtocol
  weak var view: LaunchesTableControllerProtocol?
  let rocketName: String

  init(view: LaunchesTableControllerProtocol?, networkService: NetworkServiceProtocol, rocketId: String, rocketName: String) {
    self.rocketName = rocketName
    self.rocketId = rocketId
    self.networkService = networkService
  }

  private func getItems(from launches: [RocketLaunch.Doc]) -> [LaunchItem] {
    launches.map {
      LaunchItem(
        title: $0.name,
        date: Date.dateFormatterRu.string(from: $0.dateLocal),
        image: $0.success ? "up" : "down"
      )
    }
  }

  func getLaunches() {
    networkService.getLaunches(forRocket: rocketId) { [weak self] result in
      guard let self = self else { return }
      DispatchQueue.main.async {
        switch result {
        case .success(let launches):
          self.view?.success(with: self.getItems(from: launches.docs))
        case .failure(let error):
          self.view?.failure(with: error)
        }
      }
    }
  }
}
