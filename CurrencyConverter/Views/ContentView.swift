//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/17/25.
//

import SwiftUI

struct ContentView: View {
    
    @State var baseCurrency = "usd"
    @State var selectedCurrencies = ["rub", "gel", "eur", "azn"]
    @State var amountText: String = ""
    @StateObject var viewModel = CurrencyViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        
        NavigationStack {
            List {
                Section("Selected currency") {
                    HStack {
                        Text(viewModel.getFlag(for: baseCurrency))
                        Text(baseCurrency.uppercased())
                        TextField("1", text: $amountText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($isTextFieldFocused)
                    }
                }
                if viewModel.isConnected {
                    Section("converted currencies") {
                        ForEach (Array(viewModel.displayCurrency(for: selectedCurrencies).enumerated()), id: \.offset) {index, item in
                            
                            CurrencyRowView(
                                item: item,
                                amountText: amountText,
                                delay: index,
                                vm: viewModel
                            )
                            .id(item.currency.code + baseCurrency)
                            .onTapGesture {
                                selectedCurrencies.append(baseCurrency)
                                selectedCurrencies.removeAll {
                                    $0 == item.currency.code
                                }
                                baseCurrency = item.currency.code
                                amountText = ""
                                viewModel.loadRates(baseCurrency: baseCurrency)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No internet connection",
                        systemImage: "wifi.slash",
                        description: Text("Check your internet connection")
                    )
                }
            }
            .navigationTitle("Currency Converter")
            
            
        }
        .onAppear() {
            viewModel.loadRates(baseCurrency: baseCurrency)
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        
    } // bodu
} // ContentView

#Preview {
    ContentView()
}
