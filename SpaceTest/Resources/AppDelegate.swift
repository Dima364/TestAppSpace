//
//  AppDelegate.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 26.06.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  // swiftlint: disable:next: discouraged_optional_collection
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    true
  }

  // MARK: UISceneSession Lifecycle
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}
