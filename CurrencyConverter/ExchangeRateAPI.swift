//
//  ExchangeRateAPI.swift
//  CurrencyConverter
//
//  Created by Jiwon Kang on 6/15/25.
//



import Foundation


class ExchangeRateAPI {
    
    private var currencies : [Currency] = []
    private var fromIndex = 0
    private var toIndex = 1
    
    private var exchangeRate: Double?
    private var date = ""
    
    // Chache last fetched currency codes to show correct display
    private var lastFromCode: String = ""
    private var lastToCode: String = ""
    
    
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
    

