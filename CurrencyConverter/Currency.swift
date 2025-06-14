//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Jiwon Kang on 6/14/25.
//

import Foundation

struct Currency: Identifiable, Codable {
    let id: UUID = UUID()   // generates new id, but won't be decoded
    
    let name: String
    let code: String
    let flag: String

    // This prevents the decoder from trying to overwrite id
    private enum CodingKeys: String, CodingKey {
        case name, code, flag
    }
}
