//
//  UserDefault.swift
//  SwissBirds
//
//  Created by Philipp on 29.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
