Currency Converter 💱
A modern iOS currency converter app built with SwiftUI that provides real-time exchange rates for currencies worldwide.
Features ✨

Real-time Exchange Rates: Get up-to-date currency conversion rates
170+ Currencies: Support for major world currencies with flag emojis
Intuitive Interface: Clean, modern SwiftUI design
Offline Awareness: Smart network monitoring with retry functionality
Custom Currency Selection: Add and remove currencies from your favorites
Quick Base Currency Switching: Tap any currency to make it your base
Animated Transitions: Smooth animations for better user experience
Persistent Settings: Remembers your selected currencies and base currency

Screenshots 📱
Add your app screenshots here
Technical Details 🛠️
Architecture

SwiftUI for modern, declarative UI
MVVM Pattern with ObservableObject ViewModels
Combine Framework for reactive data handling
Network Monitoring with NWPathMonitor

Key Components

CurrencyViewModel: Manages exchange rates and app state
CurrencySelectionViewModel: Handles currency selection logic
ExchangeRateService: Network service for fetching rates
CurrencyLoader: Loads currency data from local JSON

Data Source

Exchange rates from Fawaz Ahmed's Currency API
Local currency database with 170+ currencies and flags

Requirements 📋

iOS 15.0+
Xcode 14.0+
Swift 5.7+

Installation 🚀

Clone the repository:

bashgit clone https://github.com/yourusername/CurrencyConverter.git

Open CurrencyConverter.xcodeproj in Xcode
Build and run the project

Usage 💡

Convert Currency: Enter an amount in the base currency field
Add Currencies: Tap "Add" to select currencies for conversion
Switch Base Currency: Tap any converted currency to make it your base
Search Currencies: Use the search bar in currency selection
Refresh Rates: Pull down to refresh exchange rates

Project Structure 📁
CurrencyConverter/
├── Models/
│   ├── Currency.swift
│   └── ExchangeRateResponse.swift
├── ViewModels/
│   ├── CurrencyViewModel.swift
│   └── CurrencySelectionViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── CurrencyRowView.swift
│   └── CurrencySelectionView.swift
├── Services/
│   ├── ExchangeRateService.swift
│   └── CurrencyLoader.swift
└── Resources/
    └── world_currencies.json
API Integration 🌐
This app uses the free Currency API by Fawaz Ahmed:

Endpoint: https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/
Rate Limit: No authentication required
Update Frequency: Daily updates

Contributing 🤝

Fork the repository
Create your feature branch (git checkout -b feature/AmazingFeature)
Commit your changes (git commit -m 'Add some AmazingFeature')
Push to the branch (git push origin feature/AmazingFeature)
Open a Pull Request

Planned Features 🎯

 Historical exchange rate charts
 Currency rate alerts
 Widget support
 Dark mode optimization
 Conversion history
 Offline mode with cached rates

License 📄
This project is licensed under the MIT License - see the LICENSE file for details.
Acknowledgments 🙏

Fawaz Ahmed for the free currency API
Flag emojis from Unicode Consortium
SwiftUI community for inspiration and best practices


Made with ❤️ and SwiftUI
