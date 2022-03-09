//
//  ImageManager.swift
//  ImageCaching
//
//  Created by Victor Rubenko on 09.03.2022.
//

import Foundation
import UIKit

fileprivate struct Response: Codable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url = "image"
    }
}

final class ImageManager {
    var imageURLS = [URL]()
    private var loadedImages = [URL: UIImage]()
    private var runningTasks = [UUID: URLSessionDataTask]()
    
    func getImageURLS() -> DispatchGroup {
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 5)
        for _ in 0...10 {
            group.enter()
            URLSession.shared.dataTask(with: URL(string: "https://forza-api.tk/")!) { data, _, error in
                Thread.sleep(forTimeInterval: 0.1)
                print(Thread.current)
                do {
                    if let data = data {
                        print("GET")
                        let response = try JSONDecoder().decode(Response.self, from: data)
                        if let url = URL(string: response.url) {
                            self.imageURLS.append(url)
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                    
                }
                semaphore.signal()
                group.leave()
            }.resume()
        }
    group.notify(queue: .main) {
        print("Onde")
    }
    
    return group
}

func loadImage(_ url: URL, completion: @escaping ((Result<UIImage, Error>) -> Void)) -> UUID? {
    if let image = loadedImages[url] {
        print("cached")
        completion(.success(image))
        return nil
    }
    
    let uuid = UUID()
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        
        defer { self.runningTasks.removeValue(forKey: uuid) }
        
        if let data = data, error == nil, let image = UIImage(data: data) {
            self.loadedImages[url] = image
            completion(.success(image))
            return
        }
        if let error = error {
            if (error as NSError).code != NSURLErrorCancelled {
                completion(.failure(error))
                return
            }
        }
        return
    }
    task.resume()
    
    runningTasks[uuid] = task
    return uuid
}

func cancelLoad(_ uuid: UUID) {
    runningTasks[uuid]?.cancel()
    runningTasks.removeValue(forKey: uuid)
}
}

