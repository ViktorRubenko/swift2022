//
//  TempFormatter.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import Foundation

enum TempSign: String {
    case celcius = "C"
    case fahrenheit = "F"
    case kalvin = "K"
}

protocol TempFormatterProtocol {
    func withSign(_ value: Double, sign: TempSign) -> String
    func tempMaxMin(_ valueMax: Double, _ valueMin: Double, sign: TempSign) -> String
}

struct TempFormatter: TempFormatterProtocol {
    func withSign(_ value: Double, sign: TempSign) -> String {
        "\(Int(round(value)))°\(sign.rawValue)"
    }
    
    func tempMaxMin(_ valueMax: Double, _ valueMin: Double, sign: TempSign) -> String {
        let tempMax = Int(round(valueMax))
        let tempMin = Int(round(valueMin))
        return "Max.:\(tempMax)°\(sign.rawValue), min.:\(tempMin)°\(sign.rawValue)"
    }
}
