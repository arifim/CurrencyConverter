//
//  CurrencyRow.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/26/25.
//

import SwiftUI

struct CurrencyRowView: View {
    
    let item: DisplayCurrency
    let baseCurrency: String
    let amountText: String
    let delay: Int // The row animation delay
    @ObservedObject var vm: CurrencyViewModel
    @State private var isVisible = false
    @State private var hasAnimated = false
    
    
    var body: some View {
        HStack {
            Text(item.currency.flag)
                .font(.largeTitle)
            VStack(alignment: .leading) {
                Text(item.currency.code.uppercased())
                    .font(.title3)
                Text(item.currency.name)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if vm.isLoading {
                ProgressView()
            } else {
                VStack(alignment: .trailing) {
                    Text(convertedAmount)
                        .font(.title3).bold()
                    let formatedRate = String(format: "%.4f", item.rate)
                    Text("1 \(baseCurrency.uppercased()) = \(formatedRate) \(item.currency.code.uppercased())")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .offset(x: isVisible ? 0 : 350)
        .opacity(isVisible ? 1 : 0.5)
        .onAppear {
            
            if !hasAnimated {
                isVisible = false
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay) * 0.1) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isVisible = true
                        hasAnimated = true
                    }
                }
            } else {
                isVisible = true
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
    CurrencyRowView(item: currency, baseCurrency: "usd", amountText: "10.0", delay: 1, vm: vm)
}
