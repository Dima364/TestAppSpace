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

  required init?(coder: NSCoder) {
    userDefaultsService = UserDefaultsService()
    networkService = NetworkService()
    super.init(coder: coder)
  }

  private func getControllers() {
    self.networkService.getRockets { result in
      DispatchQueue.main.async {
        switch result {
        case .failure(let error):
          self.presentAlert(withMessage: error.localizedDescription)
        case .success(let rockets):
          self.controllerList = rockets.compactMap { rocket in
            let rocketController = self.storyboard?.instantiateViewController(identifier: "mainVC") { coder ->
              RocketController? in
              RocketController(
                coder: coder,
                rocketData: rocket
              )
            }
            return rocketController
          }
          self.setViewControllers([self.controllerList[0]], direction: .forward, animated: true, completion: nil)
        }
      }
    }
  }
}

extension RocketPageViewController: UIPageViewControllerDataSource {

  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController
  ) -> UIViewController? {
    guard let currentIndex = controllerList.firstIndex(of: viewController) else { return nil}

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
