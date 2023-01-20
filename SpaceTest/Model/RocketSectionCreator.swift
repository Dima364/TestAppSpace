//
//  RocketSectionCreator.swift
//  SpaceTest
//
//  Created by Дмитрий Помин on 19.11.2022.
//

import UIKit

final class RocketSectionCreator {
  typealias Item = Section.Item

  // MARK: - hints descriptions
  enum Hints: String, CaseIterable {
    case height = "Высота"
    case diameter = "Диаметр"
    case mass = "Масса"
    case payloadWeight = "Нагрузка"
    case firstFlight = "Первый запуск"
    case country = "Страна"
    case costPerLaunch = "Стоимость запуска"
    case firstStage = "Первая ступень"
    case engines = "Количество двигателей"
    case fuelAmountTons = "Количество топлива"
    case burnTimeSec = "Время сгорания"
    case secondStage = "Вторая ступень"
  }

  // MARK: - symbols for settings
  enum MetricSymbols: String, CaseIterable {
    case kilos = "kg"
    case pounds = "lb"
    case meters = "m"
    case feet = "ft"
  }

  private let userDefaultsService = UserDefaultsService()

  private func getHorizontalItem(forDimension dimension: Hints, data: Rocket) -> Item {
    guard let metricSymbol = userDefaultsService.getMetricType(for: dimension) else {
      return Item.button
    }

    let hint = "\(dimension.rawValue), \(metricSymbol.rawValue)"
    let value: String

    switch metricSymbol {
    case .kilos:
      value = dimension == .mass ? String(data.mass.kg) : String(data.payloadWeights[0].kg)
    case .pounds:
      value = dimension == .mass ? String(data.mass.lb) : String(data.payloadWeights[0].lb)
    case .meters:
      value = dimension == .height ? data.height.meters.toString() : data.diameter.meters.toString()
    case .feet:
      value = dimension == .height ? data.height.feet.toString() : data.diameter.feet.toString()
    }

    return Item.value(value: value, hint: hint)
  }

  func makeSections(data: Rocket) -> [Section] {
    var imageAndTitleItem = [Section.Item]()
    if let url = URL(string: data.flickrImages[0]) {
      imageAndTitleItem.append(.title(image: url, title: data.name))
    }

    return [
      Section(sectionType: .imageAndTitle, title: nil, items: imageAndTitleItem),
      Section(
        sectionType: .hScroll,
        title: nil,
        items: [
          getHorizontalItem(forDimension: .height, data: data),
          getHorizontalItem(forDimension: .diameter, data: data),
          getHorizontalItem(forDimension: .mass, data: data),
          getHorizontalItem(forDimension: .payloadWeight, data: data)
        ]
      ),
      Section(sectionType: .vScroll, title: nil, items: [
        .value(value: Date.dateFormatterRu.string(from: data.firstFlight), hint: Hints.firstFlight.rawValue),
        .value(value: data.country, hint: Hints.country.rawValue),
        .value(value: String(data.costPerLaunch.formatted(.currency(code: "USD"))), hint: Hints.costPerLaunch.rawValue)
      ]),
      Section( sectionType: .vScroll, title: "Первая ступень", items: [
        .value(value: String(data.firstStage.engines), hint: Hints.engines.rawValue),
        .value(value: String(data.firstStage.fuelAmountTons), hint: Hints.fuelAmountTons.rawValue),
        .value(value: "\(data.firstStage.burnTimeSec?.description ?? "Н/Д")", hint: Hints.burnTimeSec.rawValue)
      ]),
      Section(sectionType: .vScroll, title: "Вторая ступень", items: [
        .value(value: String(data.secondStage.engines), hint: Hints.engines.rawValue),
        .value(value: String(data.secondStage.fuelAmountTons), hint: Hints.fuelAmountTons.rawValue),
        .value(value: "\(data.secondStage.burnTimeSec?.description ?? "Н/Д")", hint: Hints.burnTimeSec.rawValue)
      ]),
      Section(sectionType: .button, title: nil, items: [Section.Item.button])
    ]
  }
}
