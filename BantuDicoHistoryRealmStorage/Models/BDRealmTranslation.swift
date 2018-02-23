//
//  BDRealmTranslation.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

public struct BDRealmTranslation {
    
    let identifier: String
    let word: String
    let language: String
    let translationLanguage: String
    let isFavorite: Bool
    let translations: [String]
}

extension BDRealmTranslation {
    init(realmTranslation: RealmTranslation) {
        identifier = realmTranslation.identifier
        word = realmTranslation.word
        language = realmTranslation.language
        translationLanguage = realmTranslation.translationLanguage
        isFavorite = realmTranslation.isFavorite
        translations = Array(realmTranslation.translations).sorted()
    }
}
