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
