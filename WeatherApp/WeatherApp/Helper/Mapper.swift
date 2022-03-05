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
        weatherFormatter: WeatherFormatterProtocol) -> WeatherData? {
            if let current = weatherResponse?.current,
               let daily = weatherResponse?.daily?.first,
               let weather = current.weather.first {
                return WeatherData(
                    temp: weatherFormatter.withSign(current.temp),
                    tempDetails: weatherFormatter.tempMaxMin(daily.temp.max, daily.temp.min),
                    weatherDescription: weather.weatherDescription.capitalized,
                    weatherIcon: mapWeatherIcon(id: weather.id)
                )
            }
            return nil
        }
    
    static func hourlyData(
        _ weatherResponse: WeatherResponse?,
        weatherFormatter: WeatherFormatterProtocol) -> [HourlyData]? {
            if let weatherResponse = weatherResponse {
                var array: [HourlyData] = weatherResponse.hourly!.compactMap({
                    let date = Date(timeIntervalSince1970: Double($0.dt))
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH"
                    dateFormatter.timeZone = TimeZone(identifier: weatherResponse.timezone)
                    return HourlyData(
                        hour: dateFormatter.string(from: date),
                        temp: weatherFormatter.withSign($0.temp),
                        weatherIcon: mapWeatherIcon(id: $0.weather.first!.id))
                })
                array[0].hour = "Now"
                return array
            }
            return nil
        }
    
    static func dailyData(
        _ weatherResponse: WeatherResponse?,
        weatherFormatter: WeatherFormatterProtocol) -> [DailyData]? {
            if let weatherResponse = weatherResponse {
                var array: [DailyData] = weatherResponse.daily!.compactMap {
                    let date = Date(timeIntervalSince1970: Double($0.dt))
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "E"
                    return DailyData(
                        day: dateFormatter.string(from: date),
                        weatherIcon: mapWeatherIcon(id: $0.weather.first!.id),
                        maxTemp: weatherFormatter.withSign($0.temp.max),
                        minTemp: weatherFormatter.withSign($0.temp.min))
                }
                array[0].day = "Today"
                return array
            }
            return nil
        }
    
    static func additionalData(_ weatherResponse: WeatherResponse?, weatherFormatter: WeatherFormatter) -> [AdditionalData]? {
        guard let weatherResponse = weatherResponse, let current = weatherResponse.current else {
            return nil
        }
        var array = [AdditionalData]()
        array.append(AdditionalData(title: "Sunrise", value: getHourAndMinutes(current.sunrise!, timeZone: weatherResponse.timezone)))
        array.append(AdditionalData(title: "Sunset", value: getHourAndMinutes(current.sunset!, timeZone: weatherResponse.timezone)))
        array.append(AdditionalData(title: "Feels like", value: weatherFormatter.withSign(current.feelsLike)))
        array.append(AdditionalData(title: "Pressure", value: String(current.pressure)))
        array.append(AdditionalData(title: "Humidity", value: "\(current.humidity)%"))
        array.append(AdditionalData(title: "Wind speed", value: weatherFormatter.windSpeed(current.windSpeed)))
        return array
    }
    
    private static func getHourAndMinutes(_ dt: Int, timeZone: String) -> String {
        let date = Date(timeIntervalSince1970: Double(dt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}
