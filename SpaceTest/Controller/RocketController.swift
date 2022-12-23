//
//  RocketController.swift
//  SpaceTest
//  Created by Дмитрий Помин on 26.06.2022.
//
import UIKit

final class RocketController: UIViewController {

  private let rawModel: Rocket
  private var sectionCreator: RocketSectionCreator
  private lazy var dataSource = configureDataSource()

  @IBOutlet private var collectionView: UICollectionView!

  init?(coder: NSCoder, rocketData: Rocket, sectionCreator: RocketSectionCreator = RocketSectionCreator()) {
    self.sectionCreator = sectionCreator
    self.rawModel = rocketData
    super.init(coder: coder)
  }

  @available (*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
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
      return SettingsController(coder: coder)
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
  private func configureDataSource() -> UICollectionViewDiffableDataSource<Section, Section.Item> {
    collectionView.collectionViewLayout = createLayout()

    let imageNib = UINib(nibName: ImageCell.reuseIdentifier, bundle: nil)
    let imageRegistration = UICollectionView.CellRegistration<ImageCell, Section.Item>(cellNib: imageNib) { cell, _, item in
      guard case let .title(image, title) = item else { return }
      cell.configure(image: image, title: title)
      cell.openSettings = { [weak self] in
        self?.performSegue(withIdentifier: "settingsSegue", sender: self)
      }
    }

    let horizontalNib = UINib(nibName: HorizontalCell.reuseIdentifier, bundle: nil)
    let horizontalRegistration = UICollectionView.CellRegistration<HorizontalCell, Section.Item>(cellNib: horizontalNib) { cell, _, item in
      guard case let .value(value, hint, _) = item else { return }
      cell.configure(value: value, hint: hint)
    }

    let infoNib = UINib(nibName: InfoCell.reuseIdentifier, bundle: nil)
    let infoRegistration = UICollectionView.CellRegistration<InfoCell, Section.Item>(cellNib: infoNib) { cell, _, item in
      guard case let .value(value, hint, _) = item else { return }
      cell.configure(value: value, hint: hint)
    }

    let buttonNib = UINib(nibName: ButtonCell.reuseIdentifier, bundle: nil)
    let buttonRegistration = UICollectionView.CellRegistration<ButtonCell, Section.Item>(cellNib: buttonNib) { cell, _, _ in
      cell.openLaunchesController = { [weak self] in
        self?.performSegue(withIdentifier: "tableSegue", sender: self)
      }
    }

    let headerRegistration = UICollectionView.SupplementaryRegistration<Header>(
      supplementaryNib: UINib(nibName: Header.reuseIdentifier, bundle: nil),
      elementKind: Header.reuseIdentifier
    ) { supplementaryView, _, indexPath in
      supplementaryView.configure(withTitle: self.dataSource.snapshot().sectionIdentifiers[indexPath.section].title)
    }

    dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
      let sectionItem = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

      switch sectionItem.sectionType {
      case .imageAndTitle:
        return collectionView.dequeueConfiguredReusableCell(using: imageRegistration, for: indexPath, item: item)
      case .button:
        return collectionView.dequeueConfiguredReusableCell(using: buttonRegistration, for: indexPath, item: item)
      case .hScroll:
        return collectionView.dequeueConfiguredReusableCell(using: horizontalRegistration, for: indexPath, item: item)
      case .vScroll:
        return collectionView.dequeueConfiguredReusableCell(using: infoRegistration, for: indexPath, item: item)
      }
    }

    dataSource.supplementaryViewProvider = { [weak self] _, _, index in
      self?.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
    }

    return dataSource
  }

  private func createLayout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout { (sectionIndex: Int, envy: NSCollectionLayoutEnvironment) in
      let sectionItem = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
      let sectionType = sectionItem.sectionType
      let section: NSCollectionLayoutSection

      switch sectionType {
      case .imageAndTitle:
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(450))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        section = NSCollectionLayoutSection(group: group)
        return section
      case .hScroll:
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15)
        return section
      case .vScroll:
        let section: NSCollectionLayoutSection
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
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
        return section
      case .button:
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(35))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        return section
      }
    }
  }
}
