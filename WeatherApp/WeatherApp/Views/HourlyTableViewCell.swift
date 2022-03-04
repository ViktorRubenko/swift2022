//
//  HourlyTableViewCell.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import UIKit

class HourlyTableViewCell: UITableViewCell {
    
    var data = [HourlyData]()
    
    private var collectionView: UICollectionView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: "SubBGColor")
        setupSubviews()
    }
    
    private func setupSubviews() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: round(88 / 1.5), height: 88)
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(HourlyCollectionViewCell.self, forCellWithReuseIdentifier: "HourlyCell")
        
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(_ data: [HourlyData]?) {
        if let data = data {
            self.data = data
            collectionView.reloadData()
        }
    }
}

extension HourlyTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCollectionViewCell
        cell.configure(data[indexPath.row])
        return cell
    
    }
}
