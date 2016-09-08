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

enum Error: ErrorType {
    case UnexpectedError(nsError: NSError?)
    case ServiceError(json: [String: AnyObject])
    case JSonSerializationError
}

typealias JSON = AnyObject
typealias JSONDictionary = [String: JSON]
typealias JSONArray = [JSON]

