//
//  BDRealmTranslationResult.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

class BDRealmTranslationResult: Object {
    
    @objc dynamic var sourceWord = ""
    @objc dynamic var sourceLanguage = ""
    @objc dynamic var destinationLanguage = ""
    @objc dynamic var isFavorite = false
    var translations = List<String>()
}
