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
      RocketPageViewController(coder: coder)
    }

    let naviga = UINavigationController(rootViewController: pageViewController)

    window.rootViewController = naviga
    self.window = window
    window.makeKeyAndVisible()
  }
}
