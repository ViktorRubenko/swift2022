//
//  SearchBarExtension.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 08.03.2022.
//

import UIKit

extension UISearchBar {

    public func setNewcolor(color: UIColor) {
        let clrChange = subviews.flatMap { $0.subviews }
        guard let sc = (clrChange.filter { $0 is UITextField }).first as? UITextField else { return }
        sc.textColor = color
    }
}
