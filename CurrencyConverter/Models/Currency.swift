//
//  Currency.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/17/25.
//

import Foundation

struct Currency: Codable, Identifiable, Equatable {
    
    let id = UUID() // This property has a default value and should not be overwritten by JSON decoding
    let code: String
    let name: String
    let flag: String
    
    // Only include properties that should be decoded from JSON
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case flag
    }
}

struct CurrencyList: Codable {
    let currencies: [Currency]
}
