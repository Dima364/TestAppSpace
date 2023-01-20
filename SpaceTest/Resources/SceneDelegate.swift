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
      guard let view = RocketPageViewController(coder: coder) else { return UIViewController() }
      let userDefaultsService = UserDefaultsService()
      let networkService = NetworkService()
      view.presenter = RocketPageViewPresenter(view: view, userDefaultsService: userDefaultsService, networkService: networkService)
      return view
    }

    let initialNavigationController = UINavigationController(rootViewController: pageViewController)

    window.rootViewController = initialNavigationController
    self.window = window
    window.makeKeyAndVisible()
  }
}
