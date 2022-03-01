//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 01.03.2022.
//

import UIKit

class DetailViewController: UIViewController {
        
    var artworkImageView: UIImageView!
    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.8, alpha: 0.85)
        
        setupSubviews()
        
        if let imageLargeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: imageLargeURL)
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    deinit {
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    private func setupSubviews() {
        let popupView = UIView()
        popupView.layer.cornerRadius = 10
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.backgroundColor = UIColor(named: "DetailBG")
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .equalSpacing
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageStackView = UIStackView()
        imageStackView.alignment = .center
        imageStackView.axis = .vertical
        
        artworkImageView = UIImageView()
        artworkImageView.clipsToBounds = true
        artworkImageView.contentMode = .scaleAspectFit
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.text = searchResult.name
        
        let artistNameLabel = UILabel()
        artistNameLabel.adjustsFontSizeToFitWidth = true
        artistNameLabel.minimumScaleFactor = 0.5
        artistNameLabel.text = searchResult.artistName
        
        let gridStackView = UIStackView()
        gridStackView.axis = .horizontal
        gridStackView.spacing = 8
        
        let firstColumnStackView = UIStackView()
        firstColumnStackView.axis = .vertical
        firstColumnStackView.spacing = 8
        
        let kindLabel = UILabel()
        kindLabel.text = "Type:"
        kindLabel.textColor = UIColor(named: "ArtistNameColor")
        kindLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let genreLabel = UILabel()
        genreLabel.text = "Genre:"
        genreLabel.textColor = UIColor(named: "ArtistNameColor")
        genreLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let secondColumnStackView = UIStackView()
        secondColumnStackView.axis = .vertical
        secondColumnStackView.spacing = 8
        
        let kindValueLabel = UILabel()
        kindValueLabel.text = searchResult.type
        
        let genreValueLabel = UILabel()
        genreValueLabel.text = searchResult.genre
        
        let priceButtonStackView = UIStackView()
        priceButtonStackView.alignment = .trailing
        priceButtonStackView.axis = .vertical
        
        let priceButton = UIButton(type: .system)
        priceButton.setTitle(
            String(price: searchResult.price, currency: searchResult.currency),
            for: .normal)
        priceButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        priceButton.setBackgroundImage(UIImage(named: "PriceButton"), for: .normal)
        priceButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        priceButton.addTarget(self, action: #selector(openInStore), for: .touchUpInside)
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        view.addSubview(popupView)
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
            popupView.widthAnchor.constraint(equalToConstant: 280),
            popupView.heightAnchor.constraint(equalToConstant: 280),
            popupView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
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
        return touch.view === self.view
    }
}
