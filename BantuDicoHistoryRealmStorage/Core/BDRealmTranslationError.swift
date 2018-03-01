//
//  BDRealmTranslationError.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 01/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

public enum BDRealmTranslationError: Error {
    
    case invalidWord(String)
    case invalidLanguage(String)
    case invalidTranslations([String])
}

extension BDRealmTranslationError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidWord(let word):
            return "Word is not valid: \(word)"
        case .invalidLanguage(let language):
            return "Language is not valid: \(language)"
        case .invalidTranslations(let translations):
            return "Translations not valid: \(translations)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidWord(_):
            return "Word should be a non empty alpha string."
        case .invalidLanguage(_):
            return "Language should be a valid language code. i.e: 'en', 'fr', 'ge', ..."
        case .invalidTranslations(_):
            return "Translations should be a non empty array of String."
        }
    }
}
