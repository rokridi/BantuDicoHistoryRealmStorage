//
//  Word.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 06/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

/// Represents a translation of a word in Realm data base.
class Word: Object {
    
    /// Identifier of the translation.
    @objc dynamic var identifier: String = ""
    
    /// The translated word.
    @objc dynamic var word = ""
    
    /// The URL to a mp3 file representing the sound of the word.
    @objc dynamic var soundURL: String = ""
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

extension Word {
    
    convenience init<T: WordRepresentable>(word: T) {
        self.init()
        identifier = word.identifier
        self.word = word.word
        soundURL = word.soundURL
    }
}

extension Word {
    
    func wordRepresentableFrom<T: WordRepresentable>(model: T.Type) -> T {
       var word = model.init()
        word.identifier = identifier
        word.word = self.word
        word.soundURL = soundURL
        
        return word
    }
}

