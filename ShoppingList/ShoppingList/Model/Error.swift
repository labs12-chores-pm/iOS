//
//  Error.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/13/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case urlSession
    case encodingData
    case decodingData
    case dataMissing
}
