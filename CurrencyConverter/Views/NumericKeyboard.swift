//
//  CustomKeyboardView2.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 9/5/25.
//

import SwiftUI

struct NumericKeyboard<ToolbarContent: View>: View {
    
    @Binding var text: String
    let toolbarContent: () -> ToolbarContent
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    init(text: Binding<String>, @ViewBuilder toolbarContent: @escaping () -> ToolbarContent) {
        _text = text
        self.toolbarContent = toolbarContent
    }
    
    var body: some View {
            NumericKeyboard()
        }
    
    @ViewBuilder
    func NumericKeyboard() -> some View {
        
        VStack(spacing: 0) {
            // Keyboard toolbar
            HStack(alignment: .center) {
                toolbarContent()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.black)
            
            // Keyboard buttons
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 5), count: 3), spacing: 5) {
                ForEach(1...9, id: \.self) { index in
                    self.keyboardButtonView(.text("\(index)")) {
                        self.text.append("\(index)")
                    }
                }
                keyboardButtonView(.text(".")) {
                    if !self.text.contains(".") {
                        self.text.append(".")
                    }
                }
                keyboardButtonView(.text("0")) {
                    if !self.text.isEmpty {
                        self.text.append("0")
                    }
                }
                keyboardButtonView(.image("delete.backward.fill")) {
                    if !self.text.isEmpty {
                        self.text.removeLast()
                    }
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background {
                Rectangle()
                    .fill(Color(.systemGray6))
                    .ignoresSafeArea()
            }
        }
    }
    
    @ViewBuilder
    func keyboardButtonView(_ value: KeyboardValue, onTap: @escaping () -> ()) -> some View {
        
        Button {
            self.impactFeedback.impactOccurred()
            onTap()
        } label: {
            ZStack {
                switch value {
                case .text(let string):
                    Text(string)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 110, height: 50)
                                .foregroundStyle(.black)
                        }
                case .image(let imageName):
                    Image(systemName: imageName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
        
    }
}

enum KeyboardValue {
    case text(String)
    case image(String)
}
