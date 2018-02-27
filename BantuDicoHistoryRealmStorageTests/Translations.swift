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
    static let addFavoriteTranslation = BDRealmTranslation(identifier: "add-en-fr", word: "add", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["ajouter"])
    static let removeFavoriteTranslation = BDRealmTranslation(identifier: "remove-en-fr", word: "remove", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["enlever"])
    static let fetchTranslation = BDRealmTranslation(identifier: "fetch-en-fr", word: "fetch", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["rechercher"])
    static let saveTranslation = BDRealmTranslation(identifier: "save-en-fr", word: "save", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["sauvegarder"])
    static let filterTranslation0 = BDRealmTranslation(identifier: "filter0-en-fr", word: "filter0", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["TR00", "TR01", "TR02"])
    static let filterTranslation1 = BDRealmTranslation(identifier: "filter1-en-fr", word: "filter1", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["TR10", "TR11", "TR12"])
    static let deleteTranslation0 = BDRealmTranslation(identifier: "delete0-en-fr", word: "delete0", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["DEL00", "DEL01", "DEL02"])
    static let deleteTranslation1 = BDRealmTranslation(identifier: "delete1-en-fr", word: "delete1", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["DEL10", "DEL11", "DEL12"])
}
