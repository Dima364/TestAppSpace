//
//  SceneDelegate.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 26.06.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else {
      return
    }

    let window = UIWindow(windowScene: windowScene)
    let storyboard = UIStoryboard(name: "Main", bundle: .main)

    let pageViewController = storyboard.instantiateViewController(identifier: "page") { coder in
      let view = RocketPageViewController(coder: coder)
      let userDefaultsService = UserDefaultsService()
      let networkService = NetworkService()
      view?.presenter = RocketPageViewPresenter(userDefaultsService: userDefaultsService, networkService: networkService)
      view?.presenter.view = view
      return view
    }

    let initialNavigationController = UINavigationController(rootViewController: pageViewController)
    initialNavigationController.navigationBar.tintColor = .white
    let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    initialNavigationController.navigationBar.titleTextAttributes = textAttributes
    window.rootViewController = initialNavigationController
    self.window = window
    window.makeKeyAndVisible()
  }
}
