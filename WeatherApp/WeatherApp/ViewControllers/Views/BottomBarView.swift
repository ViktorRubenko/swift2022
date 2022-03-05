//
//  BottomBarView.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import UIKit

class BottomBarView: UIView {

    class func bottomBar(atView parent: UIView, height: Double = 44, backgroundColor: UIColor = UIColor(named: "SubBGColor") ?? .white.withAlphaComponent(0.7), borderHeight: Double = 1, borderColor: UIColor = .lightGray) -> BottomBarView {
        
        let view = BottomBarView(frame: .zero)
        view.backgroundColor = backgroundColor
        
        parent.addSubview(view)
        view.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalTo(parent.safeAreaLayoutGuide.snp.bottom).offset(-height)
        }
        
        let borderView = UIView()
        borderView.backgroundColor = borderColor
        view.addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.height.equalTo(borderHeight)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        return view
    }
}
