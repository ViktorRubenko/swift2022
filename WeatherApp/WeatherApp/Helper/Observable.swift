//
//  Observable.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import Foundation


class Observable<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
}
