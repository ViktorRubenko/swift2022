//
//  Extensions.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 28.02.2022.
//

import UIKit


extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] url, _, error in
            if error == nil, let url = url,
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
        downloadTask.resume()
        return downloadTask
    }
}

extension String {
    init(price: Double, currency: String) {
        var priceText = ""
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        
        if price == 0 {
            priceText = "(Free)"
        } else if let text = formatter.string(from: price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        
        self = priceText
    }
}


extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let ratio = min(
            targetSize.height / size.height,
            targetSize.width / size.width
        )
        
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio)
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
