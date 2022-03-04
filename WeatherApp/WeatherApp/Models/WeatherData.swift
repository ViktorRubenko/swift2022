//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import Foundation
import CoreLocation

fileprivate func mapWeatherIcon(id: Int) -> String {
    switch id {
    case 200...202, 230...232:
        return "cloud.bolt.rain.fill"
    case 210...229:
        return "cloud.bolt.fill"
    case 300...321:
        return "cloud.drizzle.fill"
    case 500...501:
        return "cloud.rain.fill"
    case 502...531:
        return "cloud.heavyrain.fill"
    case 600...622:
        return "cloud.snow.fill"
    case 701...781:
        return "cloud.fog.fill"
    case 800:
        return "sun.max.fill"
    case 801...804:
        return "cloud.bolt.fill"
    default:
        return ""
    }
}

struct WeatherData {
    let temp: String
    let tempDetails: String
    let weatherDescription: String
    let weatherIcon: String
    
    init(weatherResponse: WeatherResponse) {
        temp = "\(weatherResponse.current!.temp)°C"
        tempDetails = ("Max.\(weatherResponse.daily!.first!.temp.max)°C " +
                       "Min.\(weatherResponse.daily!.first!.temp.min)°C")
        weatherDescription = weatherResponse.current!.weather.first!.weatherDescription.capitalized
        weatherIcon = mapWeatherIcon(id: weatherResponse.current!.weather.first!.id)
    }
}
