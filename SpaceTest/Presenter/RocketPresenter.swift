//
//  RocketPresenter.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 20.01.2023.
//

import Foundation

protocol RocketControllerProtocol: AnyObject {
  func present(from sections: [Section])
}

protocol RocketPresenterProtocol: AnyObject {
  var view: RocketControllerProtocol? { get set }
  var rocketName: String { get }
  var rocketId: String { get }
  func getSections()
}

final class RocketPresenter: RocketPresenterProtocol {
  private let rocketRawData: Rocket
  let rocketName: String
  let rocketId: String

  func getSections() {
    self.view?.present(from: rocketSectionCreator.makeSections(data: rocketRawData))
  }

  private let rocketSectionCreator: RocketSectionCreatorProtocol
  weak var view: RocketControllerProtocol?

  init(rocketRawData: Rocket, rocketSectionCreator: RocketSectionCreatorProtocol) {
    self.rocketRawData = rocketRawData
    self.rocketSectionCreator = rocketSectionCreator
    self.rocketId = rocketRawData.id
    self.rocketName = rocketRawData.name
  }
}
