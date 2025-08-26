//
//  CurrencyViewModel.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/25/25.
//

import Foundation
import Combine
import Network


class CurrencyViewModel: ObservableObject {
    
    @Published var rates: [String : Double] = [:]
    @Published var errorMessage: String?
    @Published var allCurrencies = CurrencyLoader.loadCurrencies()
    @Published var isLoading = false
    @Published var isConnected = true
    
    private var cancellables = Set<AnyCancellable>()
    private let service = ExchangeRateService()
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "NetworkMonitoring")
    
    init() {
            startNetworkMonitoring()
        }
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                
                if path.status == .satisfied && self?.rates.isEmpty == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.retryLoadingIfNeeded()
                    }
                }
            }
        }
        networkMonitor.start(queue: networkQueue)
    }
    
    private func retryLoadingIfNeeded() {
        // Only retry if we don't have data and we're not currently loading
        if rates.isEmpty && !isLoading {
            loadRates(baseCurrency: "usd") // Use your base currency
        }
    }
    
    private func handleLoadingError(_ error: Error) {
        if !isConnected {
            errorMessage = "No internet connection"
        } else if error.localizedDescription.contains("timeout") ||
                  error.localizedDescription.contains("timed out") {
            errorMessage = "Connection timeout - please check your internet"
        } else {
            errorMessage = error.localizedDescription
        }
        // Keep isLoading = true
    }
    
    func loadRates(baseCurrency: String) {
        isLoading = true
        errorMessage = nil
        
        service.fetchRates(base: baseCurrency)
            .timeout(.seconds(10), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.handleLoadingError(error)
                    // Keep isLoading = true on error - don't set to false!
                case .finished:
                    // Only gets called after successful receiveValue
                    // isLoading is already set to false in receiveValue
                    break
                }
            }, receiveValue: { [weak self] response in
                self?.rates = response.rates[baseCurrency] ?? [:]
                self?.isLoading = false  // Only set to false when we successfully get data
                self?.errorMessage = nil  // Clear any previous errors
            })
            .store(in: &cancellables)
    }
    
    func displayCurrency(for selectedCurrency: [String]) -> [DisplayCurrency] {
        
        let filtered = allCurrencies.filter { selectedCurrency.contains($0.code) }
        
        return filtered.map { currency in
            let rate = rates[currency.code] ?? 0.0
            return DisplayCurrency(currency: currency, rate: rate)
        }
    }
    
    func getFlag(for code: String) -> String {
        
        let currency = allCurrencies.first { c in
            c.code == code
        }
        guard let currency = currency else {return ""}
        return currency.flag
    }
}

struct TimeoutError: Error, LocalizedError {
    var errorDescription: String? {
        return "Connection timeout - please check your internet"
    }
}
