//
//  CurrencySelectionView.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/27/25.
//

import SwiftUI


struct CurrencySelectionView: View {
    
    @StateObject private var viewModel: CurrencySelectionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    let baseCurrency: String
    
    let onSave: ([String]) -> Void
    let onBaseCurrencyRemoved: (String) -> Void
    
    var filteredCurrencies: [Currency] {
        let baseFilter = searchText.isEmpty ?
        viewModel.allCurrencies :
        viewModel.allCurrencies.filter {
            $0.name.localizedStandardContains(searchText) ||
            $0.code.localizedStandardContains(searchText)
        }
        
        // Remove selected currencies from available list
        return baseFilter.filter { !viewModel.selectedCurrencies.contains($0.code) }
    }
    
    // Add filtered favorites for search
    var filteredFavorites: [Currency] {
        let favorites = viewModel.favoriteCurrencies
        
        guard !searchText.isEmpty else { return favorites }
        
        return favorites.filter {
            $0.name.localizedStandardContains(searchText) ||
            $0.code.localizedStandardContains(searchText)
        }
    }
    
    
    
    init(selectedCurrencies: [String],
         baseCurrency: String,
         onSave: @escaping ([String]) -> Void,
         onBaseCurrencyRemoved: @escaping (String) -> Void
         
    ) {
        _viewModel = StateObject(wrappedValue: CurrencySelectionViewModel(selectedCurrencies: selectedCurrencies))
        self.baseCurrency = baseCurrency
        self.onSave = onSave
        self.onBaseCurrencyRemoved = onBaseCurrencyRemoved
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !filteredFavorites.isEmpty {
                    Section("Favorite".uppercased()) {
                        ForEach(viewModel.favoriteCurrencies) { currency in
                            CurrencyRow(
                                currency: currency,
                                isSelected: true) {
                                    if currency.code == baseCurrency {
                                        handleBaseCurrencyRemoval(currency.code)
                                    } else {
                                        viewModel.toggleCurrency(currency.code)
                                    }
                                }
                        }
                    }
                }
                if !filteredCurrencies.isEmpty {
                    Section(searchText.isEmpty ? "Available Currencies".uppercased() : "Search Results".uppercased()) {
                        ForEach(filteredCurrencies) { currency in
                            CurrencyRow(
                                currency: currency,
                                isSelected: false) {
                                    viewModel.toggleCurrency(currency.code)
                                }
                        }
                    }
                } else if !searchText.isEmpty {
                    // Show no results message
                    Section {
                        Text("No currencies found")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .searchable(text: $searchText)
            .listStyle(.plain)
            .navigationTitle("Select Currencies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {  // Add toolbar with Done button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSave(viewModel.selectedCurrencies) // Save changes
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func handleBaseCurrencyRemoval(_ currencyCode: String) {
        viewModel.removeCurrency(currencyCode)
        
        // Find new base currency (first remaining currency or default to USD)
        let newBaseCurrency = viewModel.selectedCurrencies.first ?? "usd"
        
        // If no currencies left, add USD
        if viewModel.selectedCurrencies.isEmpty {
            viewModel.addCurrency("usd")
        }
        
        onBaseCurrencyRemoved(newBaseCurrency)
    }
}

struct CurrencyRow: View {
    
    let currency: Currency
    let isSelected: Bool
    let onToggle: () -> Void
    
    
    var body: some View {
        HStack {
            Text(currency.flag)
            Text(currency.code.uppercased())
                .padding(.horizontal)
            Text(currency.name)
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : Color.gray.opacity(0.4))
                .font(.title3)
        }
        .onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                onToggle()
            }
        }
        
        
    }
}


#Preview {
    NavigationStack {
        CurrencySelectionView(selectedCurrencies: ["usd", "rub", "eur"], baseCurrency: "usd") {_ in
            
        } onBaseCurrencyRemoved:  { _ in
            
        }
        
    }
}
