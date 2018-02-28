//
//  BDRealmStorageError.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 28/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

public enum BDRealmStorageError: Error {
    
    case invalidWord(String)
    case invalidLanguage(String)
    case invalidTranslations([String])
    
    var localizedDescription: String {
        
        switch self {
        case .invalidWord(let word):
            return "Invalid word: \(word). It should be a non empty alpha string."
        case .invalidLanguage(let language):
            return "Invalid language: \(language). It should be a valid language code. i.e: 'en', 'fr', 'ge', ..."
        case .invalidTranslations(let translations):
            return "Invalid translations: \(translations). Translations should be a non empty array of String."
        }
    }
}
