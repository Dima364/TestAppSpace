//
//  LaunchesPresenter.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 14.01.2023.
//

import Foundation

protocol LaunchesTableControllerProtocol: AnyObject {
  func success(withLaunches launches: [RocketLaunch.Doc])
  func failure(withError error: Error)
}

protocol LaunchesPresenterProtocol: AnyObject {
  func getLaunches()
  var rocketName: String { get }
}

final class LaunchesPresenter: LaunchesPresenterProtocol {
  weak var view: LaunchesTableControllerProtocol?
  private let rocketId: String
  private let networkService: NetworkServiceProtocol
  let rocketName: String

  init(view: LaunchesTableControllerProtocol, networkService: NetworkServiceProtocol, rocketId: String, rocketName: String) {
    self.view = view
    self.rocketName = rocketName
    self.rocketId = rocketId
    self.networkService = networkService
  }

  func getLaunches() {
    networkService.getLaunches(forRocket: rocketId) { [weak self] result in
      guard let self = self else { return }
      DispatchQueue.main.async {
        switch result {
        case .success(let launches):
          self.view?.success(withLaunches: launches.docs)
        case .failure(let error):
          self.view?.failure(withError: error)
        }
      }
    }
  }
}
