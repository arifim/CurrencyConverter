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
                        .font(.title2).bold()
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
                guard !hasAnimated else {
                    isVisible = true
                    return
                }
                
                isVisible = false
                let animationDelay = Double(delay) * AnimationConstants.baseDelay
                
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                    withAnimation(.easeOut(duration: AnimationConstants.animationDuration)) {
                        isVisible = true
                        hasAnimated = true
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

private struct AnimationConstants {
    static let slideOffset: CGFloat = 350
    static let baseDelay: Double = 0.1
    static let animationDuration: Double = 0.2
    static let initialOpacity: Double = 0.5
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
