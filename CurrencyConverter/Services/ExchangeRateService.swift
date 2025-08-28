//
//  ExchangeRateService.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/23/25.
//

import Foundation
import Combine

enum ExchangeRateError: Error {
    case invalidURL
}

class ExchangeRateService {
    
    private let baseURL = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/"
    
    func fetchRates(baseCurrancy: String) -> AnyPublisher<ExchangeRateResponce, Error> {
        
        let urlString = "\(baseURL)\(baseCurrancy).json"
        guard let url = URL(string: urlString) else {
            return Fail(error: ExchangeRateError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ExchangeRateResponce.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}


