//
//  CurrencyLoader.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/17/25.
//

import Foundation


final class CurrencyLoader {
    
    static func loadCurrencies() -> [Currency] {
        
        guard let url = Bundle.main.url(forResource: "world_currencies", withExtension: "json") else {
            print("Error while loading JSON of world currencies")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(CurrencyList.self, from: data)
            return decodedData.currencies
        } catch let error {
            print("Error in reading or decoding data. - \(error.localizedDescription)")
            return []
        }
        
    }
}
