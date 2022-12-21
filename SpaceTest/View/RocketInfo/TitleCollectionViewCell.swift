//
//  TitleCollectionVIewCell.swift
//  SpaceTest
//  swiftlint: disable all
//  Created by Дмитрий Помин on 13.07.2022.
//

import UIKit

class TitleCollectionViewCell: UICollectionViewCell {

    var strings: [String]?
    var buttonPressed: (() -> Void)?

    @IBAction func button(_ sender: Any) {
        buttonPressed?()
        print("sadasd")
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let secondVc = storyboard.instantiateViewController(withIdentifier: "SettingsController") as! SettingsController
//       // secondVc.settingsStrings = strings
//
//        if let vc = self.next(ofType: UIViewController.self) {
//            vc.present(secondVc, animated: true, completion: nil)
//        }
    }
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false

        self.layer.cornerRadius = 35
        self.contentView.isUserInteractionEnabled = false
    }

    func configure(data: RocketInfoResponce, strings: [String]) {
        label.text = data.name
        self.strings = strings
    }
}

extension UIResponder {
    func next<T:UIResponder>(ofType: T.Type) -> T? {
        let r = self.next
        if let r = r as? T ?? r?.next(ofType: T.self) {
            return r
        } else {
            return nil
        }
    }
}

