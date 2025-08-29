//
//  CurrencyViewModel.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/25/25.
//

import SwiftUI
import Combine
import Network


class CurrencyViewModel: ObservableObject {
    
    @AppStorage("basecurrency") var baseCurrency: String = "usd"
    @Published var rates: [String : Double] = [:]
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isConnected = true
    @Published var allCurrencies = CurrencyLoader.loadCurrencies()
    @Published var selectedCurrencies: [String] = [] {
        didSet {
            UserDefaults.standard.set(selectedCurrencies, forKey: "selectedcurrencies")
        }
    }
    
    private lazy var currencyLookup: [String : Currency] = {
        Dictionary(uniqueKeysWithValues: allCurrencies.map { ($0.code, $0) })
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let service = ExchangeRateService()
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "NetworkMonitoring")
    private var lastLoadedBaseCurrency: String?
    private var lastRateUpdate: Date?
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes
    
    init() {
        selectedCurrencies = UserDefaults.standard.stringArray(forKey: "selectedcurrencies") ?? ["eur"]
        baseCurrency = UserDefaults.standard.string(forKey: "basecurrency") ?? "usd"
        startNetworkMonitoring()
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isConnected = path.status == .satisfied
                
                if path.status == .satisfied && self.rates.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + NetworkConstants.retryDelay) { [weak self] in
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
            loadRates()
        }
    }
    
    private func handleLoadingError(_ error: Error) {
        if !isConnected {
            errorMessage = "No internet connection"
        } else if let urlError = error as? URLError, urlError.code == .timedOut {
            errorMessage = "Connection timeout - please check your internet"
        } else {
            errorMessage = error.localizedDescription
        }
        isLoading = false  // Always stop loading on error
    }
    
    private var shouldRefreshRates: Bool {
        guard let lastUpdate = lastRateUpdate else { return true }
        return Date().timeIntervalSince(lastUpdate) > cacheValidityDuration
    }
    
    func loadRates(baseCurrency: String) {
        
        if lastLoadedBaseCurrency == baseCurrency && !rates.isEmpty && !shouldRefreshRates {
            return
        }
        
        isLoading = true
        errorMessage = nil
        lastLoadedBaseCurrency = baseCurrency
        
        service.fetchRates(baseCurrancy: baseCurrency)
            .timeout(.seconds(NetworkConstants.requestTimeout), scheduler: DispatchQueue.main)
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
                guard let self = self else { return }
                self.rates = response.rates[baseCurrency] ?? [:]
                self.lastRateUpdate = Date()
                self.isLoading = false  // Only set to false when we successfully get data
                self.errorMessage = nil  // Clear any previous errors
                
            })
            .store(in: &cancellables)
    }
    
    func userSelectedCurrencies() -> [DisplayCurrency] {
                
        let filtered = selectedCurrencies.compactMap { code -> DisplayCurrency? in
            guard code != baseCurrency,
                  let currency = currencyLookup[code] else { return nil}
            let rate = rates[code] ?? 0.0
            return DisplayCurrency(currency: currency, rate: rate)
        }
        
        return filtered
    }
    
    // Flag lookup using dictionary
    func getFlag(for code: String) -> String {
        return currencyLookup[code]?.flag ?? "🏳️"
    }
    
    func getCurrancyName(for code: String) -> String {
        return currencyLookup[code]?.name ?? "Unknown Currency"
    }
    
    func loadRates() {
        loadRates(baseCurrency: baseCurrency)
    }
    
    
    
    func swapBaseCurrency(to newCurrency: String) {
        guard newCurrency != baseCurrency else { return }
        if !selectedCurrencies.contains(baseCurrency) {
            selectedCurrencies.append(baseCurrency)
        }
        baseCurrency = newCurrency
        loadRates()
    }

    func removeBaseCurrencyFromSelection() {
        selectedCurrencies = selectedCurrencies.filter { $0 != baseCurrency }
    }
    
    func refreshRates() {
        lastLoadedBaseCurrency = nil
        loadRates()
    }
    
    func retryLoadingRates() {
        errorMessage = nil
        loadRates()
    }
}

private struct NetworkConstants {
    static let retryDelay: Double = 1.0
    static let requestTimeout: Double = 10.0
}
