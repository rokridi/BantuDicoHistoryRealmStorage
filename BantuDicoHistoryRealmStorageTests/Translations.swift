//
//  Translations.swift
//  BantuDicoHistoryRealmStorageTests
//
//  Created by Mohamed Aymen Landolsi on 23/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
@testable import BantuDicoHistoryRealmStorage

struct Translations {
    static let addFavoriteTranslation = BDRealmTranslation(word: "add", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["ajouter"])
    static let removeFavoriteTranslation = BDRealmTranslation(word: "remove", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["enlever"])
    static let fetchTranslation = BDRealmTranslation(word: "fetch", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["rechercher"])
    static let saveTranslation = BDRealmTranslation(word: "save", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["sauvegarder"])
    static let filterTranslation0 = BDRealmTranslation(word: "filter0", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["TR00", "TR01", "TR02"])
    static let filterTranslation1 = BDRealmTranslation(word: "filter1", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["TR10", "TR11", "TR12"])
    static let deleteTranslation0 = BDRealmTranslation(word: "delete0", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["DEL00", "DEL01", "DEL02"])
    static let deleteTranslation1 = BDRealmTranslation(word: "delete1", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["DEL10", "DEL11", "DEL12"])
}
