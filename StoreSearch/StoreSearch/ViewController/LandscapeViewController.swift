//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 02.03.2022.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var search: Search!
    private var firstTime = true
    private var tasks = [URLSessionDataTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        setupSubviews()
    }
    
    func setupSubviews() {
        scrollView = UIScrollView(frame: .zero)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        
        pageControl = UIPageControl()
        pageControl.numberOfPages = 0
        pageControl.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
        view.addSubview(pageControl)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let pageControlHeight = 20.0
        let yPageControl = safeFrame.size.height - pageControlHeight - 10
        scrollView.frame = CGRect(x: safeFrame.origin.x, y: safeFrame.origin.y, width: safeFrame.size.width, height: yPageControl - 5 - safeFrame.origin.y)
        pageControl.frame = CGRect(
            x: safeFrame.origin.x,
            y: yPageControl,
            width: safeFrame.width,
            height: pageControlHeight)
        
        if firstTime {
            firstTime = false
            switch search.state {
                case .results(let list):
                    titleButtons(list)
                case .loading:
                    showSpinner()
                case .noResults:
                    showNothingFoundLabel()
                case .notSearchedYet:
                    break
            }
        }
    }
    
    deinit {
        stopTasks()
    }
    
    // MARK: - Actions
    @objc func pageChanged(_ sender: UIPageControl) {
        UIView.animate(
            withDuration: 0.5) {
                self.scrollView.contentOffset = CGPoint(
                    x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                    y: 0)
            }
    }
    
    @objc func showDetails(_ sender: UIButton) {
        if case .results(let list) = search.state {
            let searchResult = list[sender.tag]
            let vc = DetailViewController()
            vc.searchResult = searchResult
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - Helper Methods
    private func stopTasks() {
        tasks.forEach { task in
            task.cancel()
        }
        tasks.removeAll()
    }
    private func titleButtons(_ searchResults: [SearchResult]) {
        
        let itemWidth: CGFloat = 94
        let itemHeight: CGFloat = 88
        var columnsPerPage = 0
        var rowsPerPage = 0
        var marginX: CGFloat = 0
        var marginY: CGFloat = 0
        let viewWidth = scrollView.bounds.size.width
        let viewHeight = scrollView.bounds.size.height
        
        columnsPerPage = Int(viewWidth / itemWidth)
        rowsPerPage = Int(viewHeight / itemHeight)
        
        marginX = (viewWidth - (CGFloat(columnsPerPage) * itemWidth)) * 0.5
        marginY = (viewHeight - (CGFloat(rowsPerPage) * itemHeight)) * 0.5
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
            let button = UIButton(type: .custom)
            button.backgroundColor = .white
            button.frame = CGRect(
                x: x + paddingHorz,
                y: marginY + paddingVert + itemHeight * CGFloat(row),
                width: buttonWidth,
                height: buttonHeight)
            button.tag = index
            button.addTarget(self, action: #selector(showDetails), for: .touchUpInside)
            button.backgroundColor = .clear
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            downloadImage(for: result, button: button)
            scrollView.addSubview(button)
            
            row += 1
            if row == rowsPerPage {
                row = 0; column += 1; x += itemWidth
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
        
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages) * viewWidth,
            height: viewHeight)
    }
    
    private func downloadImage(for searchResult: SearchResult, button: UIButton) {
        if let url = URL(string: searchResult.imageSmall) {
            let task = URLSession.shared.dataTask(
                with: URLRequest(url: url)) { data, _, error in
                    if error == nil,
                       let data = data,
                       let image = UIImage(data: data) {
                        DispatchQueue.main.async{
                            button.setImage(image.resize(targetSize: CGSize(width: 60, height: 60)), for: .normal)
                        }
                    }
                }
            tasks.append(task)
            task.resume()
        }
    }
    
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .large)
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        spinner.center = CGPoint(
            x: safeFrame.midX,
            y: safeFrame.midY)
        spinner.tag = 1000
        spinner.startAnimating()
        view.addSubview(spinner)
    }
    
    private func hideSpinner() {
        if let spinner = view.viewWithTag(1000) {
            spinner.removeFromSuperview()
        }
    }
    
    func searchResultsRecieved() {
        hideSpinner()
        switch search.state {
        case .notSearchedYet, .loading:
            break
        case .noResults:
            showNothingFoundLabel()
        case .results(let list):
            titleButtons(list)
        }
    }
    
    private func showNothingFoundLabel() {
        hideSpinner()
        let label = UILabel()
        label.text = NSLocalizedString("Nothing Found", comment: "Localized kind: Nothing Found")
        label.center = CGPoint(
            x: scrollView.bounds.midX,
            y: scrollView.bounds.midY)
        label.sizeToFit()
        view.addSubview(label)
    }
}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = page
    }
}
