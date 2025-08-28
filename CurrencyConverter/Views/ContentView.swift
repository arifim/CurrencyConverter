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
    @State private var showingCurrencySelection = false
    
    @State var amountText: String = ""
    
    
    var body: some View {
        
        NavigationStack {
            List {
                selectedCurrencySection
                if viewModel.isConnected {
                    if !viewModel.userSelectedCurrencies().isEmpty {
                        convertedCurrenciesSection
                    } else {
                        noCurrenciesSelected
                    }
                } else {
                    noInternetConnection
                }
            }
            .refreshable(action: {
                viewModel.refreshRates()
            })
            .navigationTitle("Currency Converter")
            .toolbar {
                ToolbarItem {
                    Button("Add") {
                        showingCurrencySelection.toggle()
                    }
                }
            }
            .sheet(isPresented: $showingCurrencySelection) {  // Add this sheet
                CurrencySelectionView(selectedCurrencies: viewModel.selectedCurrencies, baseCurrency: viewModel.baseCurrency) { newSelection in
                    viewModel.selectedCurrencies = newSelection  // Save changes back
                } onBaseCurrencyRemoved: { newBaseCurrency in
                    viewModel.baseCurrency = newBaseCurrency
                    viewModel.loadRates()
                }
            }
        }
        .onAppear() {
            setupInitialData()
        }
    }
    
    // MARK: - View Components
    private var noInternetConnection: some View {
        ContentUnavailableView(
            "No internet connection",
            systemImage: "wifi.slash",
            description: Text("Check your internet connection")
        )
    }
    
    private var selectedCurrencySection: some View {
        Section("Selected currency") {
            HStack {
                Text(viewModel.getFlag(for: viewModel.baseCurrency))
                    .font(.largeTitle)
                Text(viewModel.baseCurrency.uppercased())
                    .font(.title3)
                TextField("1", text: $amountText)
                    .multilineTextAlignment(.trailing)
                    .font(.title3).bold()
                    .foregroundStyle(.blue)
                    .keyboardType(.decimalPad)
                    .focused($isTextFieldFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Clear") {
                                amountText = ""
                            }
                            Spacer()
                            Button("Done") {
                                isTextFieldFocused = false
                            }
                        }
                        
                    }
            }
        }
    }
    
    private var convertedCurrenciesSection: some View {
        Section("converted currencies") {
            if let errorMessage = viewModel.errorMessage {
                // Show error state with retry option
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button("Try Again") {
                        viewModel.refreshRates()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                // Show normal currency rows
                ForEach(indexedCurrencies, id: \.offset) { index, item in
                    CurrencyRowView(
                        item: item,
                        baseCurrency: viewModel.baseCurrency,
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
    }
    
    
    private var noCurrenciesSelected: some View {
        ContentUnavailableView(
            "No Currencies Selected",
            systemImage: "plus.circle",
            description: Text("Tap 'Add' to select currencies for conversion")
        )
    }
    
    // MARK: - Actions
    private func selectCurrency(_ currencyCode: String) {
        viewModel.swapBaseCurrency(to: currencyCode)
        amountText = ""
    }
    
    private func setupInitialData() {
        //        viewModel.removeBaseCurrencyFromSelection()
        viewModel.loadRates()
    }
    
    private var indexedCurrencies: [EnumeratedSequence<[DisplayCurrency]>.Element] {
        Array(viewModel.userSelectedCurrencies().enumerated())
    }
    
} // ContentView

#Preview {
    ContentView()
}
