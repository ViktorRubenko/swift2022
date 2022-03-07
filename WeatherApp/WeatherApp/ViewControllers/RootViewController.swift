//
//  RootViewController.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import UIKit
import SnapKit

class RootViewController: UIViewController {

    private let weatherPageViewController = WeatherPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private let pageControl = UIPageControl()
    private let viewContainer = UIView()
    private let locationsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "list.dash"), for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
    
        let bottomBarView = BottomBarView.bottomBar(atView: view, backgroundColor: UIColor(named: "SubBGColor")!)
        
        locationsButton.addTarget(self, action: #selector(pushLocationsList), for: .touchUpInside)
        bottomBarView.addSubview(locationsButton)
        locationsButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-25)
        }
        
        bottomBarView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(locationsButton.snp.top)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(viewContainer)
        viewContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBarView.snp.top)
        }
        
        view.sendSubviewToBack(viewContainer)
        
        let childVC = weatherPageViewController
        childVC.pageControl = pageControl
        addChild(childVC)
        viewContainer.addSubview(childVC.view)
        childVC.view.snp.makeConstraints { make in
            make.edges.equalTo(viewContainer.snp.edges)
        }
        childVC.didMove(toParent: self)
    }
    
    @objc func pushLocationsList() {
        var vc: LocationsListViewController? = LocationsListViewController()
        var navigationVC: UINavigationController? = UINavigationController(rootViewController: vc!)
        vc!.completion = { [weak self] openIndex in
            self?.weatherPageViewController.openIndex.value = openIndex
            vc!.dismiss(animated: true, completion: nil)
            navigationVC?.dismiss(animated: true, completion: nil)
            navigationVC = nil
            vc = nil
        }
        navigationVC!.modalPresentationStyle = .fullScreen
        present(navigationVC!, animated: true, completion: nil)
    }
}
