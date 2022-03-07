//
//  ViewController.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 03.03.2022.
//

import UIKit
import SnapKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    private var viewModel: WeatherViewModel!
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refreshControl = UIRefreshControl()
    private var dailyData = [DailyData]()
    private var additionalData = [AdditionalData]()
    private var activityIndicator: UIActivityIndicatorView?
    private var autoLocation = true
    
    init(placeName: String? = nil, location: CLLocation? = nil) {
        super.init(nibName: nil, bundle: nil)
        if location != nil {
            autoLocation = false
        }
        viewModel = WeatherViewModel(placeName: placeName, location: location)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(viewModel.placeName.value, "DEINIT")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignBackground()
        setupSubviews()
        setupObservers()
        
        showLoadingScreen()
        
        autoLocation ? viewModel.updateLocation() : viewModel.updateForecast()
    }
    
    func setupSubviews() {
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Updating...", comment: "Updating..."))
        refreshControl.addTarget(self, action: #selector(updateForecast), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.register(
            MainTableViewCell.self,
            forCellReuseIdentifier: MainTableViewCell.identifier)
        tableView.register(
            HourlyTableViewCell.self,
            forCellReuseIdentifier: HourlyTableViewCell.identifier)
        tableView.register(
            DailyTableViewCell.self,
            forCellReuseIdentifier: DailyTableViewCell.identifier)
        tableView.register(
            HeaderTableViewCell.self,
            forCellReuseIdentifier: HeaderTableViewCell.identifier)
        tableView.register(
            AdditionalTableViewCell.self,
            forCellReuseIdentifier: AdditionalTableViewCell.identifier)
        tableView.register(
            HeaderTableViewCell.self,
            forCellReuseIdentifier: HeaderTableViewCell.identifier)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
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
    
    func setupObservers() {
        viewModel.weatherResponse.bind {[weak self] value in
            DispatchQueue.main.async{ [weak self] in
                self?.dailyData = Mapper.dailyData(self?.viewModel.weatherResponse.value, weatherFormatter: WeatherFormatter()) ?? [DailyData]()
                
                self?.additionalData = Mapper.additionalData(self?.viewModel.weatherResponse.value, weatherFormatter: WeatherFormatter()) ?? [AdditionalData]()
                
                if self!.refreshControl.isRefreshing {
                    self!.refreshControl.endRefreshing()
                }
                self?.tableView.reloadData()
                self?.hideLoadingScreen()
            }
        }
        
        viewModel.placeName.bind {[weak self] value in
            DispatchQueue.main.async{ [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    func showLoadingScreen() {
        if activityIndicator == nil {
            tableView.isHidden = true
            activityIndicator = UIActivityIndicatorView()
            activityIndicator!.startAnimating()
            view.addSubview(activityIndicator!)
            activityIndicator!.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
    }
    
    func hideLoadingScreen() {
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
            tableView.isHidden = false
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
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1: return 1
        case 2: return additionalData.isEmpty ? 0 : additionalData.count + 1
        case 3: return dailyData.isEmpty ? 0 : dailyData.count + 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MainTableViewCell.identifier,
                for: indexPath) as! MainTableViewCell
            cell.configure(
                placeName: viewModel.placeName.value,
                weatherData: Mapper.weatherData(
                    viewModel.weatherResponse.value,
                    weatherFormatter: WeatherFormatter())
            )
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: HourlyTableViewCell.identifier,
                for: indexPath) as! HourlyTableViewCell
            cell.configure(Mapper.hourlyData(
                viewModel.weatherResponse.value,
                weatherFormatter: WeatherFormatter())
            )
            return cell
        case 2:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: HeaderTableViewCell.identifier,
                    for: indexPath) as! HeaderTableViewCell
                cell.titleLabel.text = NSLocalizedString("DETAILS", comment: "Weather Details")
                return cell
            } else {
                let data = additionalData[indexPath.row-1]
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: AdditionalTableViewCell.identifier,
                    for: indexPath) as! AdditionalTableViewCell
                cell.configure(titleText: data.title, valueText: data.value)
                return cell
            }
        case 3:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: HeaderTableViewCell.identifier,
                    for: indexPath) as! HeaderTableViewCell
                cell.titleLabel.text = NSLocalizedString(
                    "7-DAY FORECAST",
                    comment: "Section Header for 7-day forecast")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: DailyTableViewCell.identifier,
                    for: indexPath) as! DailyTableViewCell
                cell.configure(dailyData[indexPath.row-1])
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else if indexPath.section == 1 {
            return 100
        } else if indexPath.row == 0 {
            return UITableView.automaticDimension
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView(frame: .zero)
        }
        return nil
    }
}
