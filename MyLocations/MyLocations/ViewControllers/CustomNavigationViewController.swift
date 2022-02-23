//
//  CustomNavigationViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import UIKit

class CustomNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let apperance = UINavigationBarAppearance()
        apperance.configureWithOpaqueBackground()
        navigationBar.standardAppearance = apperance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
    }

}
