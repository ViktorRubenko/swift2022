//
//  WeatherPageViewController.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import UIKit

class WeatherPageViewController: UIPageViewController {
    
    let viewModel = LocationsViewModel()
    var pageControl: UIPageControl?
    var weatherViewControllers = [WeatherViewController]()
    var openIndex = Observable<Int>(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        viewModel.locations.bind {[weak self] weatherLocations in
            print("UPDATE PAGES")
            self?.weatherViewControllers.removeAll()
            weatherLocations.forEach { weatherLocation in
                if let weatherLocation = weatherLocation {
                    self?.weatherViewControllers.append(WeatherViewController(placeName: weatherLocation.placeName, location: weatherLocation.location))
                } else {
                    self?.weatherViewControllers.append(WeatherViewController())
                }
            }
            self?.pageControl?.numberOfPages = weatherLocations.count
            self?.pageControl?.currentPage = self!.openIndex.value
            self?.setViewControllers(
                [self!.weatherViewControllers[self!.openIndex.value < weatherLocations.count ? self!.openIndex.value : 0]],
                direction: .forward,
                animated: false,
                completion: nil)
        }
        
        pageControl?.addTarget(self, action: #selector(changePage), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadLocations()
    }
    
    @objc func changePage(_ sender: UIPageControl) {
        setViewControllers([weatherViewControllers[sender.currentPage]], direction: .forward, animated: true, completion: nil)
    }
    
}

extension WeatherPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = weatherViewControllers.firstIndex(of: viewController as! WeatherViewController) else { return nil }
        let nextIndex = index - 1
        guard nextIndex > -1 else {
            return nil
        }
        return weatherViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = weatherViewControllers.firstIndex(of: viewController as! WeatherViewController) else { return nil }
        let nextIndex = index + 1
        guard nextIndex < weatherViewControllers.count else { return nil }
        return weatherViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let viewControllers = pageViewController.viewControllers {
            if let viewControllerIndex = self.weatherViewControllers.firstIndex(of: viewControllers[0] as! WeatherViewController) {
                pageControl?.currentPage = viewControllerIndex
            }
        }
    }
}
