//
//  TabController.swift
//  JRNL
//
//  Created by Vinh Nguyen on 24/04/2024.
//

import UIKit

class TabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTabBar()
    }
    
// MARK: - Tab setup
    private func setUpTabBar() {
        let journal = self.creatNav(with: "Journal", and: UIImage(systemName: "person.fill"), vc: JournalViewController())
        let map = self.creatNav(with: "Map", and: UIImage(systemName: "map"), vc: MapViewController())
        self.setViewControllers([journal, map], animated: true)
    }
    
    private func creatNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        nav.viewControllers.first?.navigationItem.title = title
        return nav
    }
}
