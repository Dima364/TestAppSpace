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
  func setControllers()
  var view: RocketPageViewControllerProtocol? { get set }
}

final class RocketPageViewPresenter: RocketPageViewPresenterProtocol {
  weak var view: RocketPageViewControllerProtocol?
  private let userDefaultsService: UserDefaultsServiceProtocol
  private let networkService: NetworkServiceProtocol

  init(
    userDefaultsService: UserDefaultsServiceProtocol,
    networkService: NetworkServiceProtocol
  ) {
    self.userDefaultsService = userDefaultsService
    self.networkService = networkService
    setDefaultSettings()
  }

  func setDefaultSettings() {
    self.userDefaultsService.makeSettingsDefaults()
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
