//
//  Functions.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import UIKit


func applicationDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func labelFactory(
    text: String,
    textColor: UIColor = .white,
    alignment: NSTextAlignment = .left,
    fontSize: CGFloat = 17,
    numberOfLines: Int = 1) -> UILabel {
    let label = UILabel()
    label.textColor = textColor
    label.text = text
    label.textAlignment = alignment
    label.font = UIFont.systemFont(ofSize: fontSize)
    label.numberOfLines = numberOfLines
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}
