//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 01.03.2022.
//

import UIKit

class DetailViewController: UIViewController {
    
    enum AnimationStyle {
        case slide, fade
    }
    var dismissStyle = AnimationStyle.slide
    
    var popupView: UIView!
    var artworkImageView: UIImageView!
    var searchResult: SearchResult!
    var backgroundView: UIView!
    var downloadTask: URLSessionDownloadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        view.backgroundColor = .clear
        backgroundView = GradientView(frame: view.bounds)
        view.addSubview(backgroundView)
        
        popupView = UIView()
        popupView.layer.cornerRadius = 10
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.backgroundColor = UIColor(named: "DetailBG")
        view.addSubview(popupView)
        
        setupSubviews()
        
        if let imageLargeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: imageLargeURL)
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillLayoutSubviews() {
        
        let portraitContraints = [
            popupView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 32),
            popupView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -32),
            popupView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            popupView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.8),
            popupView.heightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4)
        ]
        
        let landscapeConstraints = [
            popupView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 32),
            popupView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -32),
            popupView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            popupView.widthAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            popupView.widthAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4)
        ]
        
        if let orientation = view.window?.windowScene?.interfaceOrientation {
            switch orientation {
            case .unknown:
                break
            case .portrait:
                NSLayoutConstraint.activate(portraitContraints)
            default:
                NSLayoutConstraint.activate(landscapeConstraints)
            }
        }
    }
    
    deinit {
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    private func setupSubviews() {
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .equalSpacing
        mainStackView.alignment = .fill
        mainStackView.spacing = 8
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageStackView = UIStackView()
        imageStackView.alignment = .center
        imageStackView.axis = .vertical
        
        artworkImageView = UIImageView()
        artworkImageView.clipsToBounds = true
        artworkImageView.contentMode = .scaleAspectFit
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.numberOfLines = 0
        nameLabel.text = searchResult.name
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        let artistNameLabel = UILabel()
        artistNameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        artistNameLabel.text = searchResult.artistName
        artistNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        let gridStackView = UIStackView()
        gridStackView.axis = .horizontal
        gridStackView.spacing = 8
        
        let firstColumnStackView = UIStackView()
        firstColumnStackView.axis = .vertical
        firstColumnStackView.spacing = 8
        
        let kindLabel = UILabel()
        kindLabel.text = "Type:"
        kindLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        kindLabel.textColor = UIColor(named: "ArtistNameColor")
        kindLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let genreLabel = UILabel()
        genreLabel.text = "Genre:"
        genreLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        genreLabel.textColor = UIColor(named: "ArtistNameColor")
        genreLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let secondColumnStackView = UIStackView()
        secondColumnStackView.axis = .vertical
        secondColumnStackView.spacing = 8
        
        let kindValueLabel = UILabel()
        kindValueLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        kindValueLabel.text = searchResult.type
        
        let genreValueLabel = UILabel()
        genreValueLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        genreValueLabel.text = searchResult.genre
        
        let priceButtonStackView = UIStackView()
        priceButtonStackView.alignment = .trailing
        priceButtonStackView.axis = .vertical
        
        let priceButton = UIButton(type: .system)
        priceButton.setTitle(
            String(price: searchResult.price, currency: searchResult.currency),
            for: .normal)
        priceButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        priceButton.setBackgroundImage(UIImage(named: "PriceButton"), for: .normal)
        priceButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        priceButton.addTarget(self, action: #selector(openInStore), for: .touchUpInside)
        
        let config = UIImage.SymbolConfiguration(scale: .small)
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: config), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        popupView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(imageStackView)
        imageStackView.addArrangedSubview(artworkImageView)
        mainStackView.addArrangedSubview(nameLabel)
        mainStackView.addArrangedSubview(artistNameLabel)
        mainStackView.addArrangedSubview(gridStackView)
        gridStackView.addArrangedSubview(firstColumnStackView)
        gridStackView.addArrangedSubview(secondColumnStackView)
        firstColumnStackView.addArrangedSubview(kindLabel)
        firstColumnStackView.addArrangedSubview(genreLabel)
        secondColumnStackView.addArrangedSubview(kindValueLabel)
        secondColumnStackView.addArrangedSubview(genreValueLabel)
        mainStackView.addArrangedSubview(priceButtonStackView)
        priceButtonStackView.addArrangedSubview(priceButton)
        popupView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -8),
            
            mainStackView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -16),
            
            artworkImageView.widthAnchor.constraint(equalToConstant: 100),
            artworkImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
// MARK: - Actions
extension DetailViewController {
    @objc func close() {
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
    }
    
    @objc func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
// MARK: - Gesture Recognizer Delegate
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === self.backgroundView
    }
}
// MARK: - TransitioningDelegate
extension DetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .slide: return SlideOutAnimationController()
        case .fade: return FadeOutAnimationController()
        }
    }
}
