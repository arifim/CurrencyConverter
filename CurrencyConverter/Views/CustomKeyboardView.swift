//
//  CustomKeyboardView.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/31/25.
//

import SwiftUI
import AVFoundation

struct CustomKeyboardView<ToolbarContent: View>: View {
    
    @Binding var inputText: String
    let toolbarContent: () -> ToolbarContent
    
    let buttons = [
        "7", "8", "9",
        "4", "5", "6",
        "1", "2", "3",
        ".", "0", "delete",
    ]
    
    init(inputText: Binding<String>, @ViewBuilder toolbarContent: @escaping () -> ToolbarContent) {
        self._inputText = inputText
        self.toolbarContent = toolbarContent
    }
    
    var body: some View {
        VStack {
            // Toolbar
            HStack {
                toolbarContent()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 25)
            .padding(.vertical, 4)
            // Keyboard
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 3),
                spacing: 10
            ) {
                ForEach(buttons, id: \.self) { buttonText in
                    GridButton(text: buttonText, input: $inputText)
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

// MARK: - Convenience initializer for keyboard without toolbar
extension CustomKeyboardView where ToolbarContent == EmptyView {
    init(inputText: Binding<String>) {
        self._inputText = inputText
        self.toolbarContent = { EmptyView() }
    }
}

struct GridButton: View {
    
    let text: String
    let buttonWidth: CGFloat = 110
    let buttonHeight: CGFloat = 50
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    @Binding var input: String
    @State private var isPressed = false
    
    var body: some View {
        
        Button {
            handleButtonTap()
            impactFeedback.impactOccurred()
            if text == "delete" {
                AudioServicesPlayAlertSound(1155)
            } else {
                AudioServicesPlayAlertSound(1104)
            }
        } label: {
            if text == "delete" {
                Image(systemName: "delete.backward")
                    .frame(minWidth: buttonWidth, minHeight: buttonHeight)
                    .foregroundStyle(.blue)
            } else {
                Text(text)
                    .frame(minWidth: buttonWidth, minHeight: buttonHeight)
            }
        }
        .buttonStyle(PressedButtonStyle())
        
    }
    
    private func handleButtonTap() {
        switch text {
        case "delete":
            if !input.isEmpty {
                input.removeLast()
            }
        case ".":
            if !input.contains(".") {
                input += text
            }
        default:
            input += text
        }
    }
}

struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle)
            .foregroundStyle(.primary)
            .background(.gray.opacity(0.3))
            .clipShape(.buttonBorder)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
        CustomKeyboardView(inputText: .constant("")) {
            Button("Clear") {
                
            }
        }.background(.green.opacity(0.2))
}

