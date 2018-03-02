//
//  BDRealmStorageError.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 28/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

/// Error representing different error cases when managing translations' data base.
///
/// - invalidStoreName: BDRealmStorageError could not be initialized because store name is not valid.
/// - realmAccessFailed: access to Realm data base failed.
/// - realmWriteFailed: write to data base failed.
/// - translationNotFound: the requested translation is not found.
/// - dataBaseCreationFailed: data base creation failed.
/// - dataBaseAccessFailed: data base access failed.
/// - dataBaseOperationFailed: data base operation failed.
public enum BDRealmStorageError: Error {
    
    /// Data base creation failure reason.
    ///
    /// - invalidStoreName: store name is invalid.
    public enum DataBaseCreationFailureReason {
        case invalidStoreName(String)
    }
    
    /// Access to data base failure reason.
    ///
    /// - accessFailed: data base could not be accessed.
    /// - writeFailed: write to data base failed.
    public enum DataBaseAccessFailureReason {
        case accessFailed(Error)
        case writeFailed(Error)
    }
    
    /// Data base operation failure reason.
    ///
    /// - translationNotFound: the seeked translation could not be found.
    public enum DataBaseOperationFailureReason {
        case translationNotFound(identifier: String)
    }
    
    case dataBaseCreationFailed(reason: DataBaseCreationFailureReason)
    case dataBaseAccessFailed(reason: DataBaseAccessFailureReason)
    case dataBaseOperationFailed(reason: DataBaseOperationFailureReason)
}

//MARK: - LocalizedError

extension BDRealmStorageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataBaseCreationFailed(reason: let reason):
            return reason.localizedDescription
        case .dataBaseAccessFailed(reason: let reason):
          return reason.localizedDescription
        case .dataBaseOperationFailed(reason: let reason):
            return reason.localizedDescription
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .dataBaseCreationFailed(reason: let reason):
            switch reason {
            case .invalidStoreName(_):
                return "Store name should match pattern: [0-9a-zA-Z_]"
            }
        default:
            return nil
        }
    }
}

//MARK: - underlying error

extension BDRealmStorageError {
    public var underlyingError: Error? {
        switch self {
        case .dataBaseCreationFailed(reason: let reason):
            return reason.underlyingError
        case .dataBaseAccessFailed(reason: let reason):
            return reason.underlyingError
        default:
            return nil
        }
    }
}

extension BDRealmStorageError.DataBaseCreationFailureReason {
    public var underlyingError: Error? {
        return nil
    }
}

extension BDRealmStorageError.DataBaseAccessFailureReason {
    public var underlyingError: Error? {
        switch self {
        case .accessFailed(let error):
            return error
        case .writeFailed(let error):
            return error
        }
    }
}

extension BDRealmStorageError.DataBaseOperationFailureReason {
    public var underlyingError: Error? {
        return nil
    }
}

//MARK: - Localized description

extension BDRealmStorageError.DataBaseCreationFailureReason {
    public var localizedDescription: String {
        switch self {
        case .invalidStoreName(let storeName):
            return "Data base creation failed due to invalid store name: \(storeName)"
        }
    }
}

extension BDRealmStorageError.DataBaseAccessFailureReason {
    public var localizedDescription: String {
        switch self {
        case .accessFailed(let error):
            return "Data base access failed. Error: \(error.localizedDescription)"
        case .writeFailed(let error):
            return "Data base write failed. Error: \(error.localizedDescription)"
        }
    }
}

extension BDRealmStorageError.DataBaseOperationFailureReason {
    public var localizedDescription: String {
        switch self {
        case let .translationNotFound(identifier: identifier):
            return "Translation not found. Translation identifier: \(identifier)"
        }
    }
}
