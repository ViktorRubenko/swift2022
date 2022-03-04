//
//  LabelFactory.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import UIKit

class LabelFactory {
    static let shared = LabelFactory()
    
    private init() {}
    
    func centeredLabel(fontSize: CGFloat = 17.0) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .center
        return label
    }
}
