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
                if viewModel.isConnected {
                    Section("converted currencies") {
                        ForEach (indexedCurrencies, id: \.offset) {index, item in
                            
                            CurrencyRowView(
                                item: item,
                                amountText: amountText,
                                delay: index,
                                vm: viewModel
                            )
                            .id(item.currency.code + viewModel.baseCurrency)
                            .onTapGesture {
                                viewModel.selectedCurrencies.append(viewModel.baseCurrency)
                                viewModel.selectedCurrencies.removeAll {
                                    $0 == item.currency.code
                                }
                                viewModel.baseCurrency = item.currency.code
                                amountText = ""
                                viewModel.loadRates(baseCurrency: viewModel.baseCurrency)
                            }
                        }
                    }
                } else {
                    noInternetConnection
                }
            }
            .navigationTitle("Currency Converter")
            
            
        }
        .onAppear() {
            viewModel.selectedCurrencies = viewModel.selectedCurrencies.filter { $0 != viewModel.baseCurrency }
            viewModel.loadRates(baseCurrency: viewModel.baseCurrency)
        }
    } // bodu
    
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
    
} // ContentView

#Preview {
    ContentView()
}
