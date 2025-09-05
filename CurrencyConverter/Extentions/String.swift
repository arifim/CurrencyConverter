//
//  Extention+String.swift
//  CurrencyConverter
//
//  Created by arif rakhmanov on 8/28/25.
//

import Foundation

extension String {
    var isValidDecimalInput: Bool {
        // Allow empty string, numbers, and one decimal point
        let regex = "^$|^\\d*\\.?\\d*$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var sanitizedDecimalInput: String {
        // Remove any non-numeric characters except decimal point
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let filtered = self.components(separatedBy: allowedCharacters.inverted).joined()
        
        // Ensure only one decimal point
        let components = filtered.components(separatedBy: ".")
        if components.count > 2 {
            return components[0] + "." + components[1...].joined()
        }
        
        return filtered
    }
}
