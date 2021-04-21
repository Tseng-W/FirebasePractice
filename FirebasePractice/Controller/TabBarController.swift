//
//  TabBarController.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/21.
//

import UIKit
import PKHUD

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let selfId = UserDefaults.standard.string(forKey: "selfId") {
            return true
        }
        HUD.flash(.labeledError(title: "請先登入", subtitle: nil), delay: 3.0)
        return false
    }
}
