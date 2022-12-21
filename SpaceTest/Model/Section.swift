//
//  Section.swift
//  SpaceTest
//  1
//  Created by Дмитрий Помин on 20.12.2022.
//

import Foundation

struct Section: Hashable {
  enum RocketSectionType: Int, CaseIterable {
    case imageAndTitle, hScroll, vScroll, button
  }

  enum Item: Hashable {
    case title(image: URL, title: String)
    case value(value: String, hint: String, id: UUID = UUID())
    case button
  }

  let sectionType: RocketSectionType
  let title: String?
  let items: [Item]
}
