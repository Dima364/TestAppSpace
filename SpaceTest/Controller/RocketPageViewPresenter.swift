//
//  RocketPageViewPresenter.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 20.01.2023.
//

import Foundation

protocol RocketPageViewControllerProtocol: AnyObject {
  func success(with result: [Rocket])
  func failure(with error: Error)
}

protocol RocketPageViewPresenterProtocol: AnyObject {
  var networkService: NetworkServiceProtocol { get }
  var userDefaultsService: UserDefaultsServiceProtocol { get }
  func setDefaultSettings()
  func setControllers()
}

final class RocketPageViewPresenter: RocketPageViewPresenterProtocol {
  func setDefaultSettings() {
    self.userDefaultsService.makeSettingsDefaults()
  }

  weak var view: RocketPageViewControllerProtocol?
  var userDefaultsService: UserDefaultsServiceProtocol
  var networkService: NetworkServiceProtocol

  init(
    view: RocketPageViewControllerProtocol,
    userDefaultsService: UserDefaultsServiceProtocol,
    networkService: NetworkServiceProtocol
  ) {
    self.view = view
    self.userDefaultsService = userDefaultsService
    self.networkService = networkService
  }

  func setControllers() {
    self.networkService.getRockets { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let rockets):
          self.view?.success(with: rockets)
        case .failure(let error):
          self.view?.failure(with: error)
        }
      }
    }
  }
}
