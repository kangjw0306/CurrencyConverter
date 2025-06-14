//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Jiwon Kang on 6/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currencies: [Currency] = []
    @State private var fromIndex = 0
    @State private var toIndex = 1

    @State private var exchangeRate: Double?
    @State private var date = ""

    // Cache last fetched currency codes to show correct display
    @State private var lastFromCode: String = ""
    @State private var lastToCode: String = ""

    var body: some View {
        NavigationView {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                Text("Currency Converter")
                    .font(.title2)
                    .padding(.top)

                if !currencies.isEmpty {
                    Picker("From", selection: $fromIndex) {
                        ForEach(0..<currencies.count, id: \.self) { i in
                            Text("\(currencies[i].name) \(currencies[i].flag)")
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("To", selection: $toIndex) {
                        ForEach(0..<currencies.count, id: \.self) { i in
                            Text("\(currencies[i].name) \(currencies[i].flag)")
                        }
                    }
                    .pickerStyle(.menu)

                    Button("Get Rate") {
                        fetchExchangeRate()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(fromIndex == toIndex)
                } else {
                    Text("Loading currencies...")
                }

                Spacer()
            }
            .padding()
            .frame(minWidth: 250)
            .navigationTitle("Select Currencies")

            // Detail View
            GeometryReader { geometry in
                VStack {
                    Spacer()

                    if let rate = exchangeRate {
                        VStack(spacing: 8) {
                            Text("1 \(lastFromCode.uppercased()) = \(rate) \(lastToCode.uppercased())")
                                .font(.title)

                            Text("As of \(date)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("Select currencies and press 'Get Rate'")
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .navigationTitle("Exchange Rate")
        }
        .onAppear {
            currencies = loadCurrencies()
        }
    }

    func fetchExchangeRate() {
        let from = currencies[fromIndex].code
        let to = currencies[toIndex].code

        let urlString = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/\(from).json"

        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.exchangeRate = nil
                self.date = ""
                self.lastFromCode = ""
                self.lastToCode = ""
            }
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.exchangeRate = nil
                self.date = ""
            }

            guard let data = data else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let date = json["date"] as? String,
                   let inner = json[from] as? [String: Any],
                   let rate = inner[to] as? Double {
                    DispatchQueue.main.async {
                        self.exchangeRate = rate
                        self.date = date
                        self.lastFromCode = from
                        self.lastToCode = to
                    }
                }
            } catch {
                print("JSON decoding error: \(error)")
            }
        }.resume()
    }

    func loadCurrencies() -> [Currency] {
        guard let url = Bundle.main.url(forResource: "currencies", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Currency].self, from: data) else {
            print("Failed to load currencies.json")
            return []
        }
        return decoded
    }
}
