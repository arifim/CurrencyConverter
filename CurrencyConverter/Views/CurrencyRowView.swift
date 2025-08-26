//
//  CurrencyRow.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/26/25.
//

import SwiftUI

struct CurrencyRowView: View {
    
    let item: DisplayCurrency
    let amountText: String
    let delay: Int // The row animation delay
    @ObservedObject var vm: CurrencyViewModel
    @State private var isVisible = false
    
    
    var body: some View {
        HStack {
            Text(item.currency.flag)
            Text(item.currency.name)
            Spacer()
            if vm.isLoading {
                ProgressView()
            } else {
                Text(convertedAmount)
            }
        }
        .offset(x: isVisible ? 0 : 350)
        .opacity(isVisible ? 1 : 0.5)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay) * 0.1) {
                withAnimation(.easeOut(duration: 0.2)) {
                    isVisible = true
                }
            }
        }
    }
    
    private var convertedAmount: String {
        let amount = Double(amountText) ?? 1.0
        let convertedRate = item.rate * amount
        return String(format: "%.2f", convertedRate)
    }
}

#Preview {
    let currency = DisplayCurrency(
        currency: Currency(
            code: "USD",
            name: "United States Dollar",
            flag: "🇺🇸"),
        rate: 1.0)
    let vm = CurrencyViewModel()
    CurrencyRowView(item: currency, amountText: "10.0", delay: 1, vm: vm)
}
