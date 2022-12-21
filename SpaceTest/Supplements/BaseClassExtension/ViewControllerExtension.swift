//
//  ViewControllerExtension.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 20.12.2022.
//

import UIKit

extension UIViewController {
  func presentAlert(withMessage message: String) {
    let alert = UIAlertController(title: "Внимание!", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default))
    self.present(alert, animated: true, completion: nil)
  }
}
