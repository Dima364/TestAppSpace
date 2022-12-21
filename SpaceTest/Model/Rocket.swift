//
//  Rocket.swift
//  SpaceTest
// swiftlint:disable: identifier_name
//  Created by Дмитрий Помин on 26.06.2022.

import Foundation

// MARK: - RocketInfoResponce
struct Rocket: Decodable {
  let height, diameter: Diameter
  let mass: Mass
  let firstStage: FirstStage
  let secondStage: SecondStage
  let payloadWeights: [PayloadWeight]
  let flickrImages: [String]
  let costPerLaunch: Int
  let firstFlight: Date
  let country, name, id: String

  // MARK: - Diameter
  struct Diameter: Decodable {
    let meters, feet: Double
  }

  // MARK: - FirstStage
  struct FirstStage: Decodable {
    let engines: Int
    let fuelAmountTons: Double
    let burnTimeSec: Int?
  }

  // MARK: - Mass
  struct Mass: Decodable {
    let kg, lb: Int
  }

  // MARK: - PayloadWeight
  struct PayloadWeight: Decodable {
    let id, name: String
    let kg, lb: Int
  }

  // MARK: - SecondStage
  struct SecondStage: Decodable {
    let engines: Int
    let fuelAmountTons: Double
    let burnTimeSec: Int?
  }
}
