//
//  BDRealmTranslation.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

public struct BDRealmTranslation {
    
    public let identifier: String
    public let word: String
    public let language: String
    public let translationLanguage: String
    public let isFavorite: Bool
    public let translations: [String]
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
