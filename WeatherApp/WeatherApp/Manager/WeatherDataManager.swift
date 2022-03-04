//
//  WeatherDataManager.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 03.03.2022.
//

import Foundation

enum WeatherManagerError: Error {
    case failedRequest
    case invalidResponse
    case unknown
}

class WeatherDataManager {
    
    typealias WeatherDataCompletion = (Result<WeatherResponse,WeatherManagerError>) -> Void
    
    enum Units: String {
        case metric, imperial, standard
    }
    
    enum Language: String {
        case en, fr, ru, es, de
    }
    
    static let shared = WeatherDataManager()
    
    private let appID = "e41cb2ac3eef6ce33f44bd481da7d890"
    
    private init() {}
    
    func weatherDataAt(
        latitude: Double,
        longitude: Double,
        units: Units = .metric,
        language: Language = .en,
        completion: @escaping WeatherDataCompletion) {
            
            var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/onecall")!
            components.queryItems = [
                URLQueryItem(name: "lat", value: "\(latitude)"),
                URLQueryItem(name: "lon", value: "\(longitude)"),
                URLQueryItem(name: "appid", value: "\(appID)"),
                URLQueryItem(name: "units", value: units.rawValue),
                URLQueryItem(name: "lang", value: language.rawValue),
                URLQueryItem(name: "exclude", value: "minutely")
            ]
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) { data, response, error in
                self.didFinishFetchingWeatherData(
                    data: data,
                    response: response,
                    error: error,
                    completion: completion)
            }.resume()
        }
    
    func didFinishFetchingWeatherData(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: WeatherDataCompletion) {
            if error != nil {
                completion(.failure(.failedRequest))
                return
            }
            if let data = data, let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    do {
                        let decoder = JSONDecoder()
                        let weatherData = try decoder.decode(WeatherResponse.self, from: data)
                        completion(.success(weatherData))
                    } catch {
                        print(error)
                        completion(.failure(.invalidResponse))
                    }
                } else {
                    completion(.failure(.failedRequest))
                }
            } else {
                completion(.failure(.unknown))
            }
        }
}

