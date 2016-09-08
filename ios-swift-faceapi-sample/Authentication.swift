/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import Foundation

struct Authentication {
    var authenticationProvider: NXOAuth2AuthenticationProvider?
        {
        get {
            return NXOAuth2AuthenticationProvider.sharedAuthProvider()
        }
    }
}

extension Authentication {
    /**
     Authenticates to Microsoft Graph. 
     If a user has previously signed in before and not disconnected, silent log in
     will take place. 
     If not, authentication will ask for credentials
     */
    func connectToGraph(withClientId clientId: String,
                                     scopes: [String],
                                     completion:(result: GraphResult<JSON, Error>) -> Void) {
    
        // Set client ID
        NXOAuth2AuthenticationProvider.setClientId(clientId, scopes: scopes)
        
        // Try silent log in. This will attempt to sign in if there is a previous successful
        // sign in user information.
        if NXOAuth2AuthenticationProvider.sharedAuthProvider().loginSilent() == true {
            completion(result: .Success(""))
        }
        // Otherwise, present log in controller.
        else {
            NXOAuth2AuthenticationProvider.sharedAuthProvider()
                .loginWithViewController(nil) { (error: NSError?) in
                    
                    if let nsError = error {
                        completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
                    }
                    else {
                        completion(result: .Success(""))
                    }
            }
        }
    }
    
    func disconnect() {
        NXOAuth2AuthenticationProvider.sharedAuthProvider().logout()
    }
    
    func isConnected() -> Bool {
        if NXOAuth2AuthenticationProvider.sharedAuthProvider().loginSilent() == true {
            return true
        }
        else {
            return false
        }
    }
}
