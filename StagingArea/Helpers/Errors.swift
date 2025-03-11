//
//  errors.swift
//  StagingArea
//
//  Created by Amos Deane on 27/09/2023.
//

import Foundation

enum DataError: Error {
    case AuthenticationFailure
    case NetworkTimeout
    case NoData
    case UnknownError
    case couldntEncodeNamePass
    case badResponseCode

}

//enum NetError: Error {
//    case couldntEncodeNamePass
//    case badResponseCode
//}
