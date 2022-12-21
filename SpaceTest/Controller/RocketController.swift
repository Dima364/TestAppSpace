//
//  RocketController.swift
//  SpaceTest
//  Created by Дмитрий Помин on 26.06.2022.
//
import UIKit

final class RocketController: UIViewController {

  private let sectionCreator = RocketSectionCreator()
  private let rawModel: Rocket
  private var dataSource: UICollectionViewDiffableDataSource<Section, Section.Item>!

  @IBOutlet private var collectionView: UICollectionView!

  init?(coder: NSCoder, rocketData: Rocket) {
    rawModel = rocketData
    super.init(coder: coder)
  }

  @available (*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureDataSource()
    makeSections(fromData: rawModel)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    makeSections(fromData: rawModel)
  }

  @IBSegueAction
  func segueLaunches(_ coder: NSCoder) -> LaunchesTableController? {
    LaunchesTableController(coder: coder, rocketId: rawModel.id, rocketName: rawModel.name)
  }

  @IBSegueAction
  func segueSettings(_ coder: NSCoder) -> SettingsController? {
    guard let settingsController = SettingsController(coder: coder) else {
      return SettingsController()
    }
    settingsController.settingsUpdate = {
      self.makeSections(fromData: self.rawModel)
    }
    return settingsController
  }

  private func makeSections(fromData: Rocket) {
    switch sectionCreator.makeSections(data: rawModel) {
    case .success(let sections):
      applySnapshots(withSections: sections)
    case .failure(let error):
      DispatchQueue.main.async {
        self.presentAlert(withMessage: error.localizedDescription)
      }
    }
  }

  private func applySnapshots(withSections sections: [Section]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>()

    for section in sections {
      snapshot.appendSections([section])
      snapshot.appendItems(section.items, toSection: section)
    }
    dataSource.apply(snapshot)
  }
}

// MARK: - dataSource configuration
extension RocketController {
  private func configureDataSource() {
    collectionView.collectionViewLayout = createLayout()

    let imageNib = UINib(nibName: ImageCell.reuseIdentifier, bundle: nil)
    let imageRegistration = UICollectionView.CellRegistration<ImageCell, Section.Item>(cellNib: imageNib) { cell, _, item in
      guard case let .title(image, title) = item else {
        return
      }
      cell.configure(image: image, title: title)
      cell.buttonPressed = { [weak self] in
        self?.performSegue(withIdentifier: "settingsSegue", sender: self)
      }
    }

    let hNib = UINib(nibName: CustomCollectionViewCell.reuseIdentifier, bundle: nil)
    let hRegistration = UICollectionView.CellRegistration<CustomCollectionViewCell, Section.Item>(cellNib: hNib) { cell, _, item in
      guard case let .value(value, hint, _) = item else {
        return
      }
      cell.configure(value: value, hint: hint)
    }

    let vNib = UINib(nibName: InfoCell.reuseIdentifier, bundle: nil)
    let vRegistration = UICollectionView.CellRegistration<InfoCell, Section.Item>(cellNib: vNib) { cell, _, item in
      guard case let .value(value, hint, _) = item else {
        return
      }
      cell.configure(value: value, hint: hint)
    }

    let buttonNib = UINib(nibName: ButtonCell.reuseIdentifier, bundle: nil)
    let buttonRegistration = UICollectionView.CellRegistration<ButtonCell, Section.Item>(cellNib: buttonNib) { cell, _, _ in
      cell.buttonClick = { [weak self] in
        self?.performSegue(withIdentifier: "tableSegue", sender: self)
      }
    }

    let headerRegistration = UICollectionView.SupplementaryRegistration<Header>(
      supplementaryNib: UINib(nibName: Header.reuseIdentifier, bundle: nil),
      elementKind: Header.reuseIdentifier
    ) { supplementaryView, _, indexPath in
      supplementaryView.configure(withTitle: self.dataSource.snapshot().sectionIdentifiers[indexPath.section].title)
    }

    dataSource = UICollectionViewDiffableDataSource<Section, Section.Item>(
      collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
        let sectionItem = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

        switch sectionItem.sectionType {
        case .imageAndTitle:
          return collectionView.dequeueConfiguredReusableCell(using: imageRegistration, for: indexPath, item: item)
        case .button:
          return collectionView.dequeueConfiguredReusableCell(using: buttonRegistration, for: indexPath, item: item)
        case .hScroll:
          return collectionView.dequeueConfiguredReusableCell(using: hRegistration, for: indexPath, item: item)
        case .vScroll:
          return collectionView.dequeueConfiguredReusableCell(using: vRegistration, for: indexPath, item: item)
        }
    }

    dataSource.supplementaryViewProvider = { [weak self] _, _, index in
      self?.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
    }
  }
}

// MARK: - layout configuration
extension RocketController {
  private func createLayout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) ->
      NSCollectionLayoutSection? in
      let sectionItem = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
      let sectionType = sectionItem.sectionType
      let section: NSCollectionLayoutSection
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)

      switch sectionType {
      case .imageAndTitle:
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(450))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        section = NSCollectionLayoutSection(group: group)
      case .hScroll:
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(125), heightDimension: .estimated(125))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15)
      case .vScroll:
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        if sectionItem.title != nil {
          let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
          let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: Header.reuseIdentifier,
            alignment: .top
          )
          section.boundarySupplementaryItems = [sectionHeader]
        }
      case .button:
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
      }
      return section
    }
  }
}
