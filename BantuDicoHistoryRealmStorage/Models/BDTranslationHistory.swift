//
//  BDTranslationHistory.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

public struct BDTranslationHistory {
    
    let sourceWord: String
    let sourceLanguage: String
    let destinationLanguage: String
    let isFavorite: Bool
    let translations: [String]
}

extension BDTranslationHistory {
    init(realmTranslationResult: BDRealmTranslationResult) {
        sourceWord = realmTranslationResult.sourceWord
        sourceLanguage = realmTranslationResult.sourceWord
        destinationLanguage = realmTranslationResult.destinationLanguage
        isFavorite = realmTranslationResult.isFavorite
        translations = Array(realmTranslationResult.translations).sorted()
    }
}
