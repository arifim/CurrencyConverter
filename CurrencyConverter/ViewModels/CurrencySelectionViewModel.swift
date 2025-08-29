//
//  CurrencySelectionViewModel.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/27/25.
//

import Foundation
import SwiftUI


class CurrencySelectionViewModel: ObservableObject {
    
    @Published var selectedCurrencies: [String]
    
    let allCurrencies = CurrencyLoader.loadCurrencies()
    
    init(selectedCurrencies: [String]) {
        self.selectedCurrencies = selectedCurrencies
    }
    
    // MARK: computed proporties
    var availableCurrencies: [Currency] {
        allCurrencies.filter { !selectedCurrencies.contains($0.code) }
    }
    
    var favoriteCurrencies: [Currency] {
        selectedCurrencies.compactMap { code in
            allCurrencies.first { $0.code == code}
        }
    }
    
    // MARK: Bussines logic
    func addCurrency(_ code: String) {
        if !selectedCurrencies.contains(code) {
            selectedCurrencies.append(code)
        }
    }
    
    func removeCurrency(_ code: String) {
        selectedCurrencies.removeAll { $0 == code }
    }
    
    func toggleCurrency(_ code: String) {
        if selectedCurrencies.contains(code) {
            removeCurrency(code)
        } else {
            addCurrency(code)
        }
    }
}
