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
                
                TextField("1.00", text: $amountText)
                    .multilineTextAlignment(.trailing)
                    .font(.title3).bold()
                    .foregroundStyle(isValidAmount ? .blue : .red)
                    .keyboardType(.decimalPad)
                    .focused($isTextFieldFocused)
                    .onChange(of: amountText) { _, newValue in
                        // Sanitize input in real-time
                        let sanitized = newValue.sanitizedDecimalInput
                        if sanitized != newValue {
                            amountText = sanitized
                            // Add haptic feedback for invalid input
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                        
                        // Limit to reasonable length (e.g., 10 characters)
                        if amountText.count > 10 {
                            amountText = String(amountText.prefix(10))
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Clear") {
                                amountText = ""
                            }
                            .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button("Done") {
                                isTextFieldFocused = false
                            }
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        }
                    }
            }
            
            // Add validation message if needed
            if !amountText.isEmpty && !isValidAmount {
                Text("Please enter a valid number")
                    .font(.caption)
                    .foregroundColor(.red)
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
                let currencies = viewModel.userSelectedCurrencies()
                // Show normal currency rows
                ForEach(currencies.indices, id: \.self) { index in
                    let item = currencies[index]
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
    
    private var isValidAmount: Bool {
        amountText.isEmpty || (Double(amountText) != nil && Double(amountText)! >= 0)
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
