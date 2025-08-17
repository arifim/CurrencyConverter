//
//  Currency.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/17/25.
//

import Foundation

struct Currency: Codable, Identifiable, Equatable {
    
    let id = UUID()
    let code: String
    let name: String
    let flag: String
}

struct CurrencyList: Codable {
    let currencies: [Currency]
}
