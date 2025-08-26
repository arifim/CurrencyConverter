//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/17/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = CurrencyViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    @State var amountText: String = ""
    
    
    var body: some View {
        
        NavigationStack {
            List {
                selectedCurrencySection
                if viewModel.isConnected {
                    convertedCurrenciesSection
                } else {
                    noInternetConnection
                }
            }
            .navigationTitle("Currency Converter")
        }
        .onAppear() {
            setupInitialData()
        }
    } // body
    
    private var indexedCurrencies: [EnumeratedSequence<[DisplayCurrency]>.Element] {
        Array(viewModel.userSelectedCurrencies().enumerated())
    }
    
    private var noInternetConnection: some View {
        ContentUnavailableView(
            "No internet connection",
            systemImage: "wifi.slash",
            description: Text("Check your internet connection")
        )
    }
    
    // MARK: - View Components
        private var selectedCurrencySection: some View {
            Section("Selected currency") {
                HStack {
                    Text(viewModel.getFlag(for: viewModel.baseCurrency))
                    Text(viewModel.baseCurrency.uppercased())
                    TextField("1", text: $amountText)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .focused($isTextFieldFocused)
                }
            }
        }
        
        private var convertedCurrenciesSection: some View {
            Section("converted currencies") {
                ForEach(indexedCurrencies, id: \.offset) { index, item in
                    CurrencyRowView(
                        item: item,
                        amountText: amountText,
                        delay: index,
                        vm: viewModel
                    )
                    .id(item.currency.code + viewModel.baseCurrency)
                    .onTapGesture {
                        selectCurrency(item.currency.code)
                    }
                }
            }
        }
    
    // MARK: - Actions
        private func selectCurrency(_ currencyCode: String) {
            viewModel.swapBaseCurrency(to: currencyCode)
            amountText = ""
        }
        
        private func setupInitialData() {
            viewModel.removeBaseCurrencyFromSelection()
            viewModel.loadRates()
        }
    
} // ContentView

#Preview {
    ContentView()
}
