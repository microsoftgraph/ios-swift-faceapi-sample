/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import Foundation

struct ApplicationConstants {
    
    // Graph information
    static let clientId = "ENTER_CLIENT_ID"
    static let scopes   = ["User.ReadBasic.All",
                           "offline_access"]
    
    // Cognitive services information
    static let ocpApimSubscriptionKey = "ENTER_SUBSCRIPTION_KEY"
}

enum NetworkError: Error {
    case unexpectedError(nsError: NSError?)
    case serviceError(json: [String: AnyObject])
    case jsonSerializationError
}

typealias JSON = AnyObject
typealias JSONDictionary = [String: JSON]
typealias JSONArray = [JSON]

