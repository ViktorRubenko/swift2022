//
//  ViewController.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 03.03.2022.
//

import UIKit
import SnapKit

fileprivate struct Constants {
    enum cellIdentifiers: String {
        case MainCell, HourlyCell
    }
}

class WeatherViewController: UIViewController {
    
    private let viewModel = WeatherViewModel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "BGColor")
        
        assignBackground()
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
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.register(
            MainTableViewCell.self,
            forCellReuseIdentifier: Constants.cellIdentifiers.MainCell.rawValue)
        tableView.register(
            HourlyTableViewCell.self,
            forCellReuseIdentifier: Constants.cellIdentifiers.HourlyCell.rawValue)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupObservers() {
        viewModel.weatherResponse.bind {[weak self] value in
            DispatchQueue.main.async{ [weak self] in
                if self!.refreshControl.isRefreshing {
                    self!.refreshControl.endRefreshing()
                }
                self?.tableView.reloadData()
            }
        }
        
        viewModel.placeName.bind {[weak self] value in
            DispatchQueue.main.async{ [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    func assignBackground() {
        let background = UIImage(named: "BGImage")
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
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
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.cellIdentifiers.MainCell.rawValue,
                for: indexPath) as! MainTableViewCell
            cell.configure(
                placeName: viewModel.placeName.value,
                weatherData: Mapper.weatherData(
                    viewModel.weatherResponse.value,
                    tempFormatter: TempFormatter())
            )
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.cellIdentifiers.HourlyCell.rawValue,
                for: indexPath) as! HourlyTableViewCell
            cell.configure(Mapper.hourlyData(
                viewModel.weatherResponse.value,
                tempFormatter: TempFormatter())
            )
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }
        return 108
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Hourly Forecast"
        }
        if section == 2 {
            return "Daily Forecast"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5
        }
        return 20
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        UIView(frame: .zero)
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        UIView()
//    }
    

}

