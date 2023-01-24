//
//  SpacePageVIewController.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 30.06.2022.
//

import UIKit

final class RocketPageViewController: UIPageViewController {
  private var controllerList = [UIViewController]()
  var presenter: RocketPageViewPresenterProtocol!

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = self
    presenter.setControllers()
  }

  private func setControllersList(fromRockets rockets: [Rocket], withPosition position: Int = 0) {
    controllerList = rockets.compactMap { rocket in
      self.storyboard?.instantiateViewController(identifier: "mainVC") { coder in
        guard let rocketController = RocketController(coder: coder) else { return UIViewController() }

        rocketController.presenter = RocketPresenter(
          rocketRawData: rocket,
          rocketSectionCreator: RocketSectionCreator(userDefaultsService: UserDefaultsService())
          )
        rocketController.presenter.view = rocketController

        rocketController.onChangeReloadList = {
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

// MARK: - RocketPageViewControllerProtocol
extension RocketPageViewController: RocketPageViewControllerProtocol {
  func success(with result: [Rocket]) {
    self.setControllersList(fromRockets: result)
  }

  func failure(with error: Error) {
    self.presentAlert(withMessage: error.localizedDescription)
  }
}
