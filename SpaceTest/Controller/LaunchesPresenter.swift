//
//  LaunchesPresenter.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 14.01.2023.
//

import Foundation

protocol LaunchesTableControllerProtocol: AnyObject {
  func success()
  func failure(withError error: Error)
}

protocol LaunchesPresenterProtocol: AnyObject {
  init(view: LaunchesTableControllerProtocol, networkService: NetworkServiceProtocol, rocketId: String, rocketName: String)
  var launches: [RocketLaunch.Doc] { get set }
  var rocketName: String { get }
  func getLaunches(forRocket rocket: String)
}

final class LaunchesPresenter: LaunchesPresenterProtocol {
  weak var view: LaunchesTableControllerProtocol?
  var launches: [RocketLaunch.Doc] = []
  var rocketName: String
  let networkService: NetworkServiceProtocol

  required init(view: LaunchesTableControllerProtocol, networkService: NetworkServiceProtocol, rocketId: String, rocketName: String) {
    self.view = view
    self.rocketName = rocketName
    self.networkService = networkService
    getLaunches(forRocket: rocketId)
  }

  func getLaunches(forRocket rocket: String) {
    networkService.getLaunches(forRocket: rocket) { [weak self] result in
      guard let self = self else { return }
      DispatchQueue.main.async {
        switch result {
        case .success(let launches):
          self.launches = launches.docs
          self.view?.success()
        case .failure(let error):
          self.view?.failure(withError: error)
        }
      }
    }
  }
}
