/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import Foundation

struct ApplicationConstants {
    
    // Graph information
    static let clientId = "231aa189-b46a-416a-9426-1295a8da42d8"
    static let scopes   = ["User.ReadBasic.All",
                           "offline_access"]
    
    // Cognitive services information
    static let ocpApimSubscriptionKey = "5ce6674319884aff819a8bdf473c3256"
    static let selectString = "surname,displayName,userPrincipalName"
    static let orderByString = "displayName"
}

enum Error: Swift.Error {
    case UnexpectedError(nsError: NSError?)
    case ServiceError(json: [String: AnyObject])
    case JSonSerializationError
}

typealias JSON = AnyObject
typealias JSONDictionary = [String: JSON]
typealias JSONArray = [JSON]

