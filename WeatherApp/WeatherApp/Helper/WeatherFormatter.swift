//
//  TempFormatter.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import Foundation

protocol WeatherFormatterProtocol {
    func withSign(_ value: Double) -> String
    func tempMaxMin(_ valueMax: Double, _ valueMin: Double) -> String
    func windSpeed(_ value: Double) -> String
}

struct WeatherFormatter: WeatherFormatterProtocol {
    func withSign(_ value: Double) -> String {
        "\(Int(round(value)))°C"
    }
    
    func tempMaxMin(_ valueMax: Double, _ valueMin: Double) -> String {
        let tempMax = Int(round(valueMax))
        let tempMin = Int(round(valueMin))
        return "Max.:\(tempMax)°C, min.:\(tempMin)°C"
    }
    
    func windSpeed(_ value: Double) -> String {
        return "\(value) m/s"
    }
    
}
