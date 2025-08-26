//
//  ExchangeRates.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/17/25.
//

import Foundation

struct ExchangeRateResponce: Codable {
    
    let date: String
    let rates: [String: [String: Double]]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        date = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: "date")!)
        
        var tempRates: [String: [String: Double]] = [:]
        for key in container.allKeys {
            if key.stringValue != "date" {
                let value = try container.decode([String: Double].self, forKey: key)
                tempRates[key.stringValue] = value
            }
        }
        rates = tempRates
    }
    
    // динамические ключи вместо жестко заданного enum
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        
        var intValue: Int? { nil }
        init?(intValue: Int) { return nil }
    }
}
