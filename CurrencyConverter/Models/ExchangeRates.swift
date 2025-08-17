//
//  ExchangeRates.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/17/25.
//

import Foundation

struct ExchangeRates: Codable {
    
    let baseCurrency: String
    let rates: [String : Double]
}
