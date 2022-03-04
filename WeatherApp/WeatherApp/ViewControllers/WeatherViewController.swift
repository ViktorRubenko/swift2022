//
//  ViewController.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 03.03.2022.
//

import UIKit
import SnapKit

class WeatherViewController: UIViewController {
    
    private let viewModel = WeatherViewModel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BGColor")
        
        setupSubviews()
        setupObservers()
        
        viewModel.updateLocation()
    }
    
    func setupSubviews() {
        refreshControl.attributedTitle = NSAttributedString(string: "Updating...")
        refreshControl.addTarget(self, action: #selector(updateForecast), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupObservers() {
        viewModel.weatherData.bind {[weak self] value in
            DispatchQueue.main.async{ [weak self] in
                if self!.refreshControl.isRefreshing {
                    self!.refreshControl.endRefreshing()
                }
                self?.tableView.reloadData()
            }
        }
    }

}

extension WeatherViewController {
    // Actions
    @objc func updateForecast() {
        viewModel.updateLocation()
    }
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 2 ? 3 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainTableViewCell
            cell.configure(
                placeName: viewModel.placeName.value,
                weatherData: viewModel.weatherData.value)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

