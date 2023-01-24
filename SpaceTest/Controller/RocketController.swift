//
//  RocketController.swift
//  SpaceTest
//  Created by Дмитрий Помин on 26.06.2022.
//
import UIKit

final class RocketController: UIViewController {
  @IBOutlet private var collectionView: UICollectionView!
  private lazy var dataSource = configureDataSource()
  var onChangeReloadList: (() -> Void)?
  var presenter: RocketPresenterProtocol!

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.presenter.getSections()
  }

  @IBSegueAction
  func segueLaunches(_ coder: NSCoder) -> LaunchesTableController? {
    let view = LaunchesTableController(coder: coder)
    let presenter = LaunchesPresenter(
      view: view,
      networkService: NetworkService(),
      rocketId: presenter.rocketId,
      rocketName: presenter.rocketName
    )
    presenter.view = view
    view?.presenter = presenter
    return view
  }

  @IBSegueAction
  func segueSettings(_ coder: NSCoder) -> SettingsController? {
    let view = SettingsController(coder: coder)
    view?.presenter = SettingsPresenter(view: view, userDefaultsService: UserDefaultsService())
    view?.presenter.view = view
    
    view?.settingsUpdate = { [weak self] in
      self?.onChangeReloadList?()
    }
    return view
  }

  private func applySnapshots(with sections: [Section]) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>()

    for section in sections {
      snapshot.appendSections([section])
      snapshot.appendItems(section.items, toSection: section)
    }
    dataSource.apply(snapshot)
  }
}

// MARK: - UICollectionViewDiffableDataSource
extension RocketController {
  private func configureDataSource() -> UICollectionViewDiffableDataSource<Section, Section.Item> {
    collectionView.collectionViewLayout = createLayout()

    let imageNib = UINib(nibName: ImageCell.reuseIdentifier, bundle: nil)
    let imageRegistration = UICollectionView.CellRegistration<ImageCell, Section.Item>(cellNib: imageNib) { [weak self] cell, _, item in
      guard case let .title(image, title) = item else { return }
      cell.configure(image: image, title: title)
      cell.openSettings = {
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
    let buttonRegistration = UICollectionView.CellRegistration<ButtonCell, Section.Item>(cellNib: buttonNib) { [weak self] cell, _, _ in
      cell.openLaunchesController = {
        self?.performSegue(withIdentifier: "tableSegue", sender: self)
      }
    }

    let headerRegistration = UICollectionView.SupplementaryRegistration<Header>(
      supplementaryNib: UINib(nibName: Header.reuseIdentifier, bundle: nil),
      elementKind: Header.reuseIdentifier
    ) { [weak self] supplementaryView, _, indexPath in
      supplementaryView.configure(withTitle: self?.dataSource.snapshot().sectionIdentifiers[indexPath.section].title)
    }

    dataSource = .init(collectionView: collectionView) { [unowned self] collectionView, indexPath, item in
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

    dataSource.supplementaryViewProvider = { [unowned self] _, _, index in
      self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
    }

    return dataSource
  }
}

// MARK: - UICollectionViewCompositionalLayout
extension RocketController {
  private func createLayout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout { [unowned self] (sectionIndex: Int, _: NSCollectionLayoutEnvironment) in
      let sectionItem = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
      let sectionType = sectionItem.sectionType

      let section: NSCollectionLayoutSection
      let groupSize: NSCollectionLayoutSize
      let group: NSCollectionLayoutGroup
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      let sectionContentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15)

      switch sectionType {
      case .imageAndTitle:
        groupSize = .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
        group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        section = .init(group: group)
      case .hScroll:
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 10)
        groupSize = .init(widthDimension: .estimated(120), heightDimension: .estimated(110))
        group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        section = .init(group: group)
        section.contentInsets = sectionContentInsets
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
      case .vScroll:
        groupSize = .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(45))
        group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        section = .init(group: group)
        section.contentInsets = sectionContentInsets
        if sectionItem.title != nil {
          let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(45))
          let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: Header.reuseIdentifier,
            alignment: .top
          )
          section.boundarySupplementaryItems = [sectionHeader]
        }
      case .button:
        groupSize = .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(45))
        group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        section = .init(group: group)
      }
      return section
    }
  }
}

// MARK: - RocketControllerProtocol
extension RocketController: RocketControllerProtocol {
  func present(from sections: [Section]) {
    applySnapshots(with: sections)
  }
}
