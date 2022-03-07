//
//  Observable.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import Foundation


class Observable<T> {
    typealias Listener = (T) -> Void
    var listeners = [Listener?]()
    var value: T {
        didSet {
            listeners.forEach {
                if $0 != nil {
                    $0!(value)
                }
            }
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping Listener) {
        self.listeners.append(listener)
    }
}
