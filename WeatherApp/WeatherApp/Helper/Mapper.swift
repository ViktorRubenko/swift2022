//
//  Mapper.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import Foundation

fileprivate func mapWeatherIcon(id: Int) -> String {
    switch id {
    case 200...299:
        return "cloud.bolt.fill"
    case 300...399:
        return "cloud.drizzle.fill"
    case 500...599:
        return "cloud.rain.fill"
    case 600...699:
        return "cloud.snow.fill"
    case 700...799:
        return "cloud.fog.fill"
    case 800:
        return "sun.max.fill"
    case 801...899:
        return "smoke.fill"
    default:
        return ""
    }
}

enum Mapper {
    static func weatherData(
        _ weatherResponse: WeatherResponse?,
        tempFormatter: TempFormatterProtocol) -> WeatherData? {
            if let current = weatherResponse?.current,
               let daily = weatherResponse?.daily?.first,
               let weather = current.weather.first {
                return WeatherData(
                    temp: tempFormatter.withSign(current.temp, sign: .celcius),
                    tempDetails: tempFormatter.tempMaxMin(daily.temp.max, daily.temp.max, sign: .celcius),
                    weatherDescription: weather.weatherDescription.capitalized,
                    weatherIcon: mapWeatherIcon(id: weather.id)
                )
            }
            return nil
        }
    
    static func hourlyData(
        _ weatherResponse: WeatherResponse?,
        tempFormatter: TempFormatterProtocol) -> [HourlyData]? {
        if let weatherResponse = weatherResponse {
            var array: [HourlyData] = weatherResponse.hourly!.compactMap({
                let date = Date(timeIntervalSince1970: Double($0.dt))
                let hour = Calendar.current.component(.hour, from: date)
                return HourlyData(
                    hour: String(format: "%02d:00", hour),
                    temp: tempFormatter.withSign($0.temp, sign: .celcius),
                    weatherIcon: mapWeatherIcon(id: $0.weather.first!.id))
            })
            array[0].hour = "Now"
            return array
        }
        return nil
    }
}
