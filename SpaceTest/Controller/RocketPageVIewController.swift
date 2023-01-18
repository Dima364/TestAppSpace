//
//  SpacePageVIewController.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 30.06.2022.
//

import UIKit

final class RocketPageViewController: UIPageViewController {

  private let networkService: NetworkService
  private let userDefaultsService: UserDefaultsService
  private var controllerList = [UIViewController]()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = self

    userDefaultsService.makeSettingsDefaults()
    getControllers()
  }

  init?(
    coder: NSCoder,
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    networkService: NetworkService = NetworkService()
  ) {
    self.userDefaultsService = userDefaultsService
    self.networkService = NetworkService()
    super.init(coder: coder)
  }

  @available (*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setControllersList(fromRockets rockets: [Rocket], withPosition position: Int = 0) {
    controllerList = rockets.compactMap { rocket in
      self.storyboard?.instantiateViewController(identifier: "mainVC") { coder in
        let rocketController = RocketController(
          coder: coder,
          rocketData: rocket
        )
        rocketController?.onChangeReloadList = {
          var currentIndex: Int {
            guard let currentController = self.viewControllers?.first else { return 0 }
            return self.controllerList.firstIndex(of: currentController) ?? 0
          }
          self.setControllersList(fromRockets: rockets, withPosition: currentIndex)
        }
        return rocketController
      }
    }
    setViewControllers([controllerList[position]], direction: .forward, animated: true)
  }

  private func getControllers() {
    self.networkService.getRockets { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let rockets):
          self.setControllersList(fromRockets: rockets)
        case .failure(let error):
          self.presentAlert(withMessage: error.localizedDescription)
        }
      }
    }
  }
}

// MARK: - UIPageViewControllerDataSource
extension RocketPageViewController: UIPageViewControllerDataSource {
  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController
  ) -> UIViewController? {
    guard let currentIndex = controllerList.firstIndex(of: viewController) else { return nil }

    if currentIndex == 0 {
      return controllerList.last
    } else {
      return controllerList[currentIndex - 1]
    }
  }

  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerAfter viewController: UIViewController
  ) -> UIViewController? {
    guard let currentIndex = controllerList.firstIndex(of: viewController) else { return nil }

    if currentIndex < controllerList.count - 1 {
      return controllerList[currentIndex + 1]
    } else {
      return controllerList.first
    }
  }

  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    controllerList.count

  }

  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    0
  }
}
