//
//  ExchangeRateServiceProtocol.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/23/25.
//

protocol ExchangeRateServiceProtocol {
    func fetchRates(base: String) async throws -> ExchangeRateResponce
}
