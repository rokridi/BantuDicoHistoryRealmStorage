//
//  String+validation.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 28/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

extension String {
    
    func isValidWord() -> Bool {
        return range(of: "^[a-zA-Z]+", options: .regularExpression) != nil
    }
    
    func isValidLanguage() -> Bool {
        return range(of: "^[a-zA-Z]{2}", options: .regularExpression) != nil
    }
    
    func isValidFileName() -> Bool {
        return range(of: "^[0-9a-zA-Z_]", options: .regularExpression) != nil
    }
}
